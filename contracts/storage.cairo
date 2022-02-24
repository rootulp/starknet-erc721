%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.uint256 import Uint256

##################
##################
## STORAGE VARS ##
##################
##################

# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity

@storage_var
func has_been_paired(contract_address : felt) -> (has_been_paired : felt):
end

@storage_var
func player_exercise_solution_storage(player_address : felt) -> (contract_address : felt):
end

@storage_var
func assigned_rank_storage(player_address : felt) -> (rank : felt):
end

@storage_var
func next_rank_storage() -> (next_rank : felt):
end

@storage_var
func max_rank_storage() -> (max_rank : felt):
end

@storage_var
func random_attributes_storage(column : felt, rank : felt) -> (value : felt):
end

@storage_var
func was_initialized() -> (was_initialized : felt):
end

@storage_var
func dummy_token_address_storage() -> (dummy_token_address_storage : felt):
end

@storage_var
func dummy_ipfs_metadata_erc721_storage() -> (dummy_ipfs_metadata_erc721_storage : felt):
end

#############
#############
## GETTERS ##
#############
#############

# Public variables should be declared explicitly with a getter

@view
func player_exercise_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        player_address : felt) -> (contract_address : felt):
    let (contract_address) = player_exercise_solution_storage.read(player_address)
    return (contract_address)
end

@view
func assigned_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        player_address : felt) -> (rank : felt):
    let (rank) = assigned_rank_storage.read(player_address)
    return (rank)
end

@view
func assigned_legs_number{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        player_address : felt) -> (legs : felt):
    let (rank) = assigned_rank(player_address)
    let (legs) = random_attributes_storage.read(0, rank)
    return (legs)
end

@view
func assigned_sex_number{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        player_address : felt) -> (sex : felt):
    let (rank) = assigned_rank(player_address)
    let (sex) = random_attributes_storage.read(1, rank)
    return (sex)
end

@view
func assigned_wings_number{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        player_address : felt) -> (wings : felt):
    let (rank) = assigned_rank(player_address)
    let (wings) = random_attributes_storage.read(2, rank)
    return (wings)
end
