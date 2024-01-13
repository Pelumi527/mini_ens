use starknet::ContractAddress;

#[starknet::interface]
trait ILilEns<TContractState> {
    fn register(ref self: TContractState, name: felt252);
    fn update(ref self: TContractState, name: felt252, new_address: ContractAddress);
    fn lookup(self: @TContractState, name: felt252) -> ContractAddress;
}

#[starknet::contract]
mod LilEns {
    use core::zeroable::Zeroable;
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        ens: LegacyMap::<felt252, ContractAddress>
    }

    #[external(v0)]
    impl LilEnsImpl of super::ILilEns<ContractState> {
        fn register(ref self: ContractState, name: felt252) {
            assert(self.ens.read(name).is_zero(), 'Error:AlreadyRegistered');
            let caller = get_caller_address();
            self.ens.write(name, caller);
        }

        fn update(ref self: ContractState, name: felt252, new_address: ContractAddress) {
            let caller: ContractAddress = get_caller_address();
            assert(caller == self.ens.read(name), 'Error:UnAuthorized');
            self.ens.write(name, new_address);
        }

        fn lookup(self: @ContractState, name: felt252) -> ContractAddress {
            self.ens.read(name)
        }
    }
}
