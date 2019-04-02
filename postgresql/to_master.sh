#/bin/bash

if [ -f "{{ postgresql_data_dir }}/recovery.conf" ];then
   touch /var/lib/pgsql/trigger_file   
fi
