#!/usr/bin/env python3

from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager
from ansible.cli.inventory import InventoryCLI
from ansible.template import Templar


# extract names
def get_names(l):
    return [e.get_name() for e in l]


# similar results to ansible-inventory --list
# https://github.com/ansible/ansible/blob/df08ed3ef38b785c2d53889be58fc580c8a27c6c/lib/ansible/cli/inventory.py#L205
def get_host_variables(host, loader, variable_manager):
    hostvars = variable_manager.get_vars(host=host, include_hostvars=False, stage="all")
    templar = Templar(variables=hostvars, loader=loader)
    templated_hostvars = templar.template(hostvars, fail_on_undefined=False)
    return InventoryCLI._remove_internal(templated_hostvars)

# be aware: ansible facts should not be used in the inventory and will not be templated, just like normal
def inventory_difference(first_inventory_source, second_inventory_source):
    loader = DataLoader()
    first_inventory = InventoryManager(loader=loader, sources=first_inventory_source)
    second_inventory = InventoryManager(loader=loader, sources=second_inventory_source)
    variable_manager = VariableManager(loader=loader, inventory=first_inventory)

    first_hosts = first_inventory.get_hosts()
    second_hosts = second_inventory.get_hosts()
    diff_hosts = [host for host in first_hosts if host.get_name() not in set(get_names(second_hosts))]

    return {
        host.get_name(): {
            "hostvars": get_host_variables(host, loader, variable_manager),
            "groups": get_names(host.get_groups()),
        }
        for host in diff_hosts
    }


class FilterModule(object):
    def filters(self):
        return {
            "inventory_difference": inventory_difference,
        }
