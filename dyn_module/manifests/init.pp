# Set the Dynect setup you are using
# 1 - Standard A records
# 2 - GSLB
# 3 - Load Balancer
# 4 - Failover (main ip address)
# 5 - Failover (failover ip address)
#
$DYNECT_TYPE = 1

#Required for adding records to any dynect account
$CUSTOMER_NAME = "<customer name>"
$USER_NAME = "<user name>"
$PASSWORD = "<password>"
$ZONE = "<zone>"
$FQDN = "<fqdn>"

# This is only required if you are using GSLB
$REGION = "<region>"


class dyn_module {
	case $DYNECT_TYPE {
		1: {
			add_a_record($CUSTOMER_NAME, $USER_NAME, $PASSWORD, $ZONE, $FQDN)
		}
		2: {
			add_address_to_gslb($CUSTOMER_NAME, $USER_NAME, $PASSWORD, $ZONE, $FQDN, $REGION)
		}
		3: {
			add_address_to_load_balance($CUSTOMER_NAME, $USER_NAME, $PASSWORD, $ZONE, $FQDN)
		}
		4: {
			update_failover_address($CUSTOMER_NAME, $USER_NAME, $PASSWORD, $ZONE, $FQDN)
		}
		5: {
			update_failover_foaddress($CUSTOMER_NAME, $USER_NAME, $PASSWORD, $ZONE, $FQDN)
		}
	}
}

