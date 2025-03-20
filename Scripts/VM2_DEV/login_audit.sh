LOG_FILE="invalid_attempts.log"

`ssh -i /path/to/private_key dev_lead1@<VM1_IP> "sudo cat /var/log/auth.log" | grep -i "invalid\|failed"` >> $LOG_FILE
# 1. Allow established and related connections (to avoid breaking existing sessions)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 2. Allow SSH traffic but track attempts using the 'recent' module
iptables -A INPUT -p tcp --dport 22 -m recent --set --name sshblock --rsource

# 3. Block IPs that exceed 3 attempts in 60 seconds
iptables -A INPUT -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 4 --name sshblock --rsource -j DROP

# 4. Allow all other SSH traffic (if not blocked)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 5. (Optional) Drop all other incoming traffic not explicitly allowed
iptables -P INPUT DROP
iptables-save > /etc/iptables/rules.v4