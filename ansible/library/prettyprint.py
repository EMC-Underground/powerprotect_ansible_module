#!/usr/bin/env python3

import ppdm
import json


test = ppdm.Ppdm(server="10.237.198.35", password="Password#1")
rule_name = "daily"
rule_id = test.get_protection_rule_by_name(rule_name)
print(rule_id)
update = test.update_protection_rule("daily", "KUBERNETES", "backup=newvalue")
