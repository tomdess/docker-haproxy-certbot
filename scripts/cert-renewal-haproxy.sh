#!/usr/bin/env bash

set -euo pipefail

# automation of certificate renewal for let's encrypt and haproxy
# - checks all certificates under /etc/letsencrypt/live and renews
#   those about about to expire in less than 4 weeks
# - creates haproxy.pem files in /etc/letsencrypt/live/domain.tld/
# - soft-restarts haproxy to apply new certificates
# usage:
# sudo ./cert-renewal-haproxy.sh

################################################################################
### global settings
################################################################################

LE_CLIENT="certbot"

HAPROXY_RELOAD_CMD="supervisorctl signal HUP haproxy"
HAPROXY_SOFTSTOP_CMD="supervisorctl signal USR1 haproxy"

WEBROOT="/jail"

# Enable to redirect output to logfile (for silent cron jobs)
# Leave it empty to log in STDOUT/ERR (docker log)
#LOGFILE="/var/log/certrenewal.log"
LOGFILE=""

################################################################################
### FUNCTIONS
################################################################################

function issueCert {
  $LE_CLIENT certonly --text --webroot --webroot-path ${WEBROOT} --renew-by-default --agree-tos --email ${EMAIL} ${1} &>/dev/null
  return $?
}

function logger_error {
  if [ -n "${LOGFILE}" ]
  then
    echo "[error] ${1}\n" >> ${LOGFILE}
  fi
  >&2 echo "[error] ${1}"
}

function logger_info {
  if [ -n "${LOGFILE}" ]
  then
    echo "[info] ${1}\n" >> ${LOGFILE}
  else
    echo "[info] ${1}"
  fi
}

################################################################################
### MAIN
################################################################################

# Before renewal, ensure any leftover validation files are removed
rm -rf ${WEBROOT}/.well-known/acme-challenge/*

le_cert_root="/etc/letsencrypt/live"

if [ ! -d ${le_cert_root} ]; then
  logger_error "${le_cert_root} does not exist!"
  exit 1
fi

# check certificate expiration and run certificate issue requests
# for those that expire in under 4 weeks
renewed_certs=()
exitcode=0
while IFS= read -r -d '' cert; do
  if ! openssl x509 -noout -checkend $((4*7*86400)) -in "${cert}"; then
    subject="$(openssl x509 -noout -subject -in "${cert}" | grep -o -E 'CN = [^ ,]+' | tr -d 'CN = ')"
    subjectaltnames="$(openssl x509 -noout -text -in "${cert}" | sed -n '/X509v3 Subject Alternative Name/{n;p}' | sed 's/\s//g' | tr -d 'DNS:' | sed 's/,/ /g')"
    domains="-d ${subject}"
    for name in ${subjectaltnames}; do
      if [ "${name}" != "${subject}" ]; then
        domains="${domains} -d ${name}"
      fi
    done
    issueCert "${domains}"
    if [ $? -ne 0 ]
    then
      logger_error "failed to renew certificate! check /var/log/letsencrypt/letsencrypt.log!"
      exitcode=1
    else
      renewed_certs+=("$subject")
      logger_info "renewed certificate for ${subject}"
    fi
  else
    logger_info "none of the certificates requires renewal"
  fi
done < <(find ${le_cert_root} -name cert.pem -print0)

# create haproxy.pem file(s)
for domain in ${renewed_certs[@]}; do
  cat ${le_cert_root}/${domain}/privkey.pem ${le_cert_root}/${domain}/fullchain.pem | tee /etc/haproxy/certs/haproxy-${domain}.pem >/dev/null
  if [ $? -ne 0 ]; then
    logger_error "failed to create haproxy.pem file!"
    exit 1
  fi
done

# soft-stop (and implicit restart) of haproxy
# (reload command does not reload certs)
if [ "${#renewed_certs[@]}" -gt 0 ]; then
  $HAPROXY_SOFTSTOP_CMD
  if [ $? -ne 0 ]; then
    logger_error "failed to stop haproxy!"
    exit 1
  fi
fi

exit ${exitcode}
