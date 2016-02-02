#!/bin/bash

# announce the override action since this is just a plain include
my_local_override_msg="Overriden by ${my_ctl_federation}"
my_ctl_functionOverrides="configContainerSSLServerKey installCertificates configShibbolethFederationValidationKey performStepsForShibbolethUpgradeIfRequired askForSaveConfigToLocalDisk "

echo -e "Overriding functions: ${my_ctl_functionOverrides}" >> ${statusFile} 2>&1


#
#       GLOBAL overrides
#
#  Things you want to be available to any BASH function in the script should be overridden here.

                echo -e "Overriding certOrg, CertCN, certC" >> ${statusFile} 2>&1
                certOrg="${freeRADIUS_svr_org_name}"
                certCN="${freeRADIUS_svr_commonName}"
                certC="CA"
                certLongC="Canada"
                certAcro="${certOrg}${certC}"

# this command takes 4min 45sec to run on a core i7 8gb ram SSD disk.
# overriding as the other yum commands
centosCmdU="yum -y update; yum clean all"
#centosCmdU="yum version"
# -y update; yum clean all"




installCertificates ()

{
			echo -e "${my_local_override_msg}" >> ${statusFile} 2>&1

			# Notes
			# 1. CAF does not have access to TCS CA's, nor needs them. 
			#This step is skipped

			${Echo} "CAF is not eligible for the GEANT TCS service, skipping steps by overriding function"


}

configShibbolethFederationValidationKey ()

{
			echo -e "${my_local_override_msg}" >> ${statusFile} 2>&1

			# Notes:
			#  1. the file of the certificate of the signer is saved as 'md-signer.crt' which is generic
			#  2. using SHA256 instead of SHA1 for fingerprint verification

			metadataSigningKeyURL="https://caf-shib2ops.ca/CoreServices/caf_metadata_verify.crt"

			# openssl x509 -noout -fingerprint -sha256 -in ./caf_metadata_verify.crt
			# SHA256 Fingerprint=
			mdSignerFingerSHA256="36:CF:D8:09:0A:88:B8:D7:52:64:E7:90:FE:A1:B6:F7:EC:BE:CF:42:C8:81:AA:F6:F4:59:D3:AE:3B:45:93:04"

			mdSignerFinger="${mdSignerFingerSHA256}"


	${fetchCmd} ${idpPath}credentials/md-signer.crt ${metadataSigningKeyURL}
	cFinger=`openssl x509 -noout -fingerprint -sha256 -in ${idpPath}/credentials/md-signer.crt | cut -d\= -f2`
	cCnt=1
	while [ "${cFinger}" != "${mdSignerFinger}" -a "${cCnt}" -le 10 ]; do
		${fetchCmd} ${idpPath}credentials/md-signer.crt ${metadataSigningKeyURL}
		cFinger=`openssl x509 -noout -fingerprint -sha256 -in ${idpPath}/credentials/md-signer.crt | cut -d\= -f2`
		cCnt=`expr ${cCnt} + 1`
	done
	if [ "${cFinger}" != "${mdSignerFinger}" ]; then
		 ${Echo} "Fingerprint error on md-signer.crt!\nGet ther certificate from ${metadataSigningKeyURL} and verify it, then place it in the file: ${idpPath}/credentials/md-signer.crt" >> ${messages}
	fi

}

# REVIEW patchShibbolethConfigs ()
# REVIEW {

#	echo -e "${my_local_override_msg}" >> ${statusFile} 2>&1

	# patch shibboleth config files
#	${Echo} "Patching config files for ${my_ctl_federation}"
#	mv /opt/shibboleth-idp/conf/attribute-filter.xml /opt/shibboleth-idp/conf/attribute-filter.xml.dist

#	${Echo} "patchShibbolethConfigs:Overlaying attribute-filter.xml with CAF defaults"

#	cp ${Spath}/files/${my_ctl_federation}/attribute-filter.xml.template /opt/shibboleth-idp/conf/attribute-filter.xml
#	chmod ugo+r /opt/shibboleth-idp/conf/attribute-filter.xml

#	${Echo} "patchShibbolethConfigs:Overlaying relying-filter.xml with CAF trusts"
#	cat ${Spath}/xml/${my_ctl_federation}/metadata-providers.xml > /opt/shibboleth-idp/conf/metadata-providers.xml
#	cat ${Spath}/xml/${my_ctl_federation}/attribute-resolver.xml > /opt/shibboleth-idp/conf/attribute-resolver.xml
 #       cat ${Spath}/files/${my_ctl_federation}/relying-party.xml > /opt/shibboleth-idp/conf/relying-party.xml

#	if [ "${consentEnabled}" = "n" ]; then
#		sed -i 's#<bean parent="Shibboleth.SSO" p:postAuthenticationFlows="attribute-release" />#<bean parent="Shibboleth.SSO" />#;s#<bean parent="SAML2.SSO" p:postAuthenticationFlows="attribute-release" />#<bean parent="SAML2.SSO" />#' /opt/shibboleth-idp/conf/relying-party.xml
#	fi

#	if [ "${google}" != "n" ]; then
#		repStr='<!-- PLACEHOLDER DO NOT REMOVE -->'
#		sed -i -e "/^${repStr}$/r ${Spath}/xml/google-filter.add" -e "/^${repStr}$/d" /opt/shibboleth-idp/conf/attribute-filter.xml
#		cat ${Spath}/xml/google-relay.diff.template | sed -re "s/IdPfQdN/${certCN}/" > ${Spath}/xml/google-relay.diff
#		files="`${Echo} ${files}` ${Spath}/xml/google-relay.diff"
#		patch /opt/shibboleth-idp/conf/relying-party.xml -i ${Spath}/xml/google-relay.diff >> ${statusFile} 2>&1
#		cat ${Spath}/xml/google.xml | sed -re "s/GoOgLeDoMaIn/${googleDom}/" > /opt/shibboleth-idp/metadata/google.xml
#	fi

#	if [ "${fticks}" != "n" ]; then
		
#		applyFTICKS

#	fi

# REVIEW	if [ "${eptid}" != "n" ]; then
 #               if [ -z "${epass}" ]; then
  #                      epass=`${passGenCmd}`
                        # grant sql access for shibboleth
  #                      cat ${Spath}/xml/${my_ctl_federation}/eptid.sql.template | sed -re "s#SqLpAsSwOrD#${epass}#" > ${Spath}/xml/${my_ctl_federation}/eptid.sql
   #                     files="`${Echo} ${files}` ${Spath}/xml/${my_ctl_federation}/eptid.sql"

    #                    ${Echo} "Create MySQL database and shibboleth user."
     #                   mysql -uroot -p"${mysqlPass}" < ${Spath}/xml/${my_ctl_federation}/eptid.sql
      #                  retval=$?
       #                 if [ "${retval}" -ne 0 ]; then
        #                        ${Echo} "Failed to create EPTID database, take a look in the file '${Spath}/xml/${my_ctl_federation}/eptid.sql.template' and corect the issue." >> ${messages}
         #                       ${Echo} "Password for the database user can be found in: /opt/shibboleth-idp/conf/attribute-resolver.xml" >> ${messages}
          #              fi
           #     fi
			
# REVIEW		cat ${Spath}/xml/${my_ctl_federation}/eptid-AR.diff.template \
# REVIEW			| sed -re "s#SqLpAsSwOrD#${epass}#;s#Large_Random_Salt_Value#${esalt}#" \
# REVIEW			> ${Spath}/xml/${my_ctl_federation}/eptid-AR.diff
# REVIEW		files="`${Echo} ${files}` ${Spath}/xml/${my_ctl_federation}/eptid-AR.diff"

	# following 2 patch lines were commented out jan 28th, 2014, but no longer
# REVIEW		cp /opt/shibboleth-idp/conf/attribute-resolver.xml /opt/shibboleth-idp/conf/attribute-resolver.xml.pre-patching

 		#patch /opt/shibboleth-idp/conf/attribute-resolver.xml -i ${Spath}/xml/${my_ctl_federation}/eptid-AR.diff >> ${statusFile} 2>&1
 		# commented out below as our default model *IS* to do this release policy
 		# patch /opt/shibboleth-idp/conf/attribute-filter.xml -i ${Spath}/xml/${my_ctl_federation}/eptid-AF.diff >> ${statusFile} 2>&1

	#	cat ${Spath}/xml/${my_ctl_federation}/eptid.add.attrCon.template \
#			| sed -re "s#SqLpAsSwOrD#${epass}#;s#Large_Random_Salt_Value#${esalt}#" \
#			> ${Spath}/xml/${my_ctl_federation}/eptid.add.attrCon
#		files="`${Echo} ${files}` ${Spath}/xml/${my_ctl_federation}/eptid.add.attrCon"

#		repStr='<!-- EPTID RESOLVER PLACEHOLDER -->'
#		sed -i -e "/^${repStr}$/r ${Spath}/xml/${my_ctl_federation}/eptid.add.resolver" -e "/^${repStr}$/d" /opt/shibboleth-idp/conf/attribute-resolver.xml

#		repStr='<!-- EPTID ATTRIBUTE CONNECTOR PLACEHOLDER -->'
#		sed -i -e "/^${repStr}$/r ${Spath}/xml/${my_ctl_federation}/eptid.add.attrCon" -e "/^${repStr}$/d" /opt/shibboleth-idp/conf/attribute-resolver.xml

#		repStr='<!-- EPTID PRINCIPAL CONNECTOR PLACEHOLDER -->'
#		sed -i -e "/^${repStr}$/r ${Spath}/xml/${my_ctl_federation}/eptid.add.princCon" -e "/^${repStr}$/d" /opt/shibboleth-idp/conf/attribute-resolver.xml

#		repStr='<!-- EPTID FILTER PLACEHOLDER -->'
#		sed -i -e "/^${repStr}$/r ${Spath}/xml/${my_ctl_federation}/eptid.add.filter" -e "/^${repStr}$/d" /opt/shibboleth-idp/conf/attribute-filter.xml
# REVIEW	fi

 #       repStr='<!-- LDAP CONNECTOR PLACEHOLDER -->'
#        sed -i -e "/^${repStr}$/r ${Spath}/xml/${my_ctl_federation}/ldapconn.txt" -e "/^${repStr}$/d" /opt/shibboleth-idp/conf/attribute-resolver.xml

#	echo "applying chown "
#	chmod o+r /opt/shibboleth-idp/conf/attribute-filter.xml

# REVIEW }


performStepsForShibbolethUpgradeIfRequired ()

{

if [ "${upgrade}" -eq 1 ]; then

${Echo} "Previous installation found, performing upgrade."

        eval ${distCmd1} &> >(tee -a ${statusFile})
        cd /opt
        currentShib=`ls -l /opt/${shibDir} | awk '{print $NF}'`
        currentVer=`${Echo} ${currentShib} | awk -F\- '{print $NF}'`
        if [ "${currentVer}" = "${shibVer}" ]; then
                mv ${currentShib} ${currentShib}.${ts}
        fi

        if [ ! -f "${downloadPath}/${shibDir}-${shibVer}.tar.gz" ]; then
                fetchAndUnzipShibbolethIdP
        fi
        tar xzf ${downloadPath}/${shibDir}-${shibVer}.tar.gz -C /opt
        chmod -R 755 /opt/${shibDir}-${shibVer}

        # Backup previous V2 environment
        #tar zcfP ${bupFile} --remove-files /opt/shibboleth-idp
        service tomcat6 stop

        if [ ! -d /opt/bak ]; then
                cp -ar /opt/shibboleth-idp /opt/bak 2>/dev/null
        fi

        rm -rf /opt/shibboleth-idp

        unlink /opt/${shibDir}
        ln -s /opt/${shibDir}-${shibVer} /opt/${shibDir}

        if [ -d "/opt/cas-client-${casVer}" ]; then
                installCasClientIfEnabled
        fi

        setJavaHome
else
        ${Echo} "This is a fresh Shibboleth Install"


fi


}


askForSaveConfigToLocalDisk ()
{

echo -e "${my_local_override_msg}" >> ${statusFile} 2>&1

# Since everything goes through the config process on the webpage, we do not need this anymore

# cAns=$(askYesNo "Save config" "Do you want to save theese config values?\n\nIf you save theese values the current config file will be ovverwritten.\n NOTE: No passwords will be saved.")

# 	if [ "${cAns}" = "y" ]; then
# 		writeConfigFile
# 	fi

# 	if [ "${GUIen}" = "y" ]; then
# 		${whiptailBin} --backtitle "${my_ctl_federation} IDP Deployer" --title "Confirm" --scrolltext --clear --textbox ${downloadPath}/confirm.tx 20 75 3>&1 1>&2 2>&3
# 	else
# 		cat ${downloadPath}/confirm.tx
# 	fi
# 	cAns=$(askYesNo "Confirm" "Do you want to install this IDP with theese options?" "no")

# 	rm ${downloadPath}/confirm.tx
# 	if [ "${cAns}" = "n" ]; then
# 		exit
# 	fi

}




