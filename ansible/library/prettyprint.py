import ppdm
import json


test = ppdm.Ppdm(server="10.237.198.35", password="Password#1")
print(json.dumps(test.get_protection_rules()))
