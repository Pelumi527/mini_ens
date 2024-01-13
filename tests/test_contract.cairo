use core::zeroable::Zeroable;
use mini_ens::ILilEnsDispatcherTrait;
use mini_ens::{ILilEnsSafeDispatcher, ILilEnsDispatcher, ILilEnsSafeDispatcherTrait};
use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank, CheatTarget};
use starknet::{get_caller_address, ContractAddress};

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}


#[test]
fn test_can_register() {
    let contract_address = deploy_contract('LilEns');
    let name: felt252 = 'Cairo';

    let safe_dispatcher = ILilEnsSafeDispatcher { contract_address };
    start_prank(CheatTarget::One(contract_address),123.try_into().unwrap());

    safe_dispatcher.register(name);
    let caller_address = safe_dispatcher.lookup(name).unwrap();
    assert(caller_address == 123.try_into().unwrap(), 'Invalid lookup');
}

#[test]
fn test_can_update() {
    let contract_address = deploy_contract('LilEns');
    let name: felt252 = 'Cairo';

    let safe_dispatcher = ILilEnsSafeDispatcher { contract_address };
    start_prank(CheatTarget::One(contract_address), 123.try_into().unwrap());
    safe_dispatcher.register(name);
    let new_address: ContractAddress = 456.try_into().unwrap();
    safe_dispatcher.update(name, new_address);
    let caller_address = safe_dispatcher.lookup(name).unwrap();
    assert(caller_address == 456.try_into().unwrap(), 'Invalid lookup');
}

#[test]
#[should_panic(expected: ('Error:AlreadyRegistered',))]
fn test_cannot_register_a_registered_name() {
    let contract_address = deploy_contract('LilEns');
    let name: felt252 = 'Cairo';

    let dispatcher = ILilEnsDispatcher { contract_address };
    dispatcher.register(name);
    dispatcher.register(name);
}

#[test]
#[should_panic(expected: ('Error:UnAuthorized',))]
fn test_address_cannot_by_unauthorized_owner() {
    let contract_address = deploy_contract('LilEns');
    let name: felt252 = 'Cairo';
    let new_address: ContractAddress = 456.try_into().unwrap();

    let dispatcher = ILilEnsDispatcher { contract_address };
    start_prank(CheatTarget::One(contract_address), 123.try_into().unwrap());
    dispatcher.register(name);
    stop_prank(CheatTarget::One(contract_address));
    start_prank(CheatTarget::One(contract_address), 456.try_into().unwrap());
    dispatcher.update(name, new_address);
}

#[test]
fn test_should_return_address_zero_for_unregistered_name() {
    let contract_address = deploy_contract('LilEns');
    let name: felt252 = 'Cairo';
    let dispatcher = ILilEnsDispatcher { contract_address };
    
    let owner = dispatcher.lookup(name);
    assert(owner.is_zero(), 'Is_Not_Zero_Address');
}

