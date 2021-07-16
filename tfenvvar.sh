cat awsid.tfvar | sed 's/ //g' | sed 's/^/export TF_VAR_/g'
