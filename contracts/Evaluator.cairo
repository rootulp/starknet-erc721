%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256

from contracts.utils.ex00_base import (
    ex_initializer, has_validated_exercise, validate_exercice, distribute_points)
from contracts.storage import (
    dummy_token_address_storage, max_rank_storage, has_been_paired,
    player_exercise_solution_storage, was_initialized, random_attributes_storage)
from contracts.token.ERC721.IERC721 import IERC721
from contracts.Exercises.Exercise_1 import ex1
from contracts.Exercises.Exercise_2 import (
    ex2a_get_animal_rank_internal, ex2b_test_declare_animal_internal)
from contracts.Exercises.Exercise_3 import ex3
from contracts.Exercises.Exercise_4 import ex4
from contracts.Exercises.Exercise_5 import ex5a, ex5b

#################
#################
# # CONSTRUCTOR ##
#################
#################
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _tderc20_address : felt, _dummy_token_address : felt, _players_registry : felt,
        _workshop_id : felt):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id)
    dummy_token_address_storage.write(_dummy_token_address)
    # Hard coded value for now
    max_rank_storage.write(100)
    return ()
end

@external
func ex1_test_erc721{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ex1()
    return ()
end

@external
func ex2a_get_animal_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # assigns a rank, and the associate characteristics expected from your animal
    alloc_locals
    # Reading caller address
    let (caller_address) = get_caller_address()
    # assigns the rank and the characteristics
    ex2a_get_animal_rank_internal(caller_address)
    return ()
end

@external
func ex2b_test_declare_animal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token_id : Uint256):
    # Checks if you minted an animal with the right characteristics
    alloc_locals
    ex2b_test_declare_animal_internal(token_id)
    return ()
end

@external
func ex3_declare_new_animal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ex3()
    return ()
end

@external
func ex4_declare_dead_animal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ex4()
    return ()
end

@external
func ex5a_i_have_dtk{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ex5a()
    return ()
end

@external
func ex5b_register_breeder{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ex5b()
    return ()
end

###
# END FUNC
@external
func submit_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        erc721_address : felt):
    # Reading caller address
    let (caller_address) = get_caller_address()
    # Checking this contract was not used by another group before
    let (has_solution_been_submitted_before) = has_been_paired.read(erc721_address)
    assert has_solution_been_submitted_before = 0

    # Assigning passed ERC721 as player ERC721
    player_exercise_solution_storage.write(caller_address, erc721_address)
    has_been_paired.write(erc721_address, 1)

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 0)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 0)
        # Sending points
        # setup points
        distribute_points(caller_address, 2)
        # Deploying contract points
        distribute_points(caller_address, 2)
    end

    return ()
end

#
# External functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercice.
#

@external
func set_random_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        values_len : felt, values : felt*, column : felt):
    # Check if the random values were already initialized
    let (was_initialized_read) = was_initialized.read()
    assert was_initialized_read = 0

    # Check that we fill max_ranK_storage cells
    let (max_rank) = max_rank_storage.read()
    assert values_len = max_rank

    # Storing passed values in the store
    set_a_random_value(values_len, values, column)

    return ()
end

@external
func finish_setup{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Check if the random values were already initialized
    let (was_initialized_read) = was_initialized.read()
    assert was_initialized_read = 0

    # Mark that value store was initialized
    was_initialized.write(1)
    return ()
end

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        values_len : felt, values : felt*, column : felt):
    if values_len == 0:
        # Start with sum=0.
        return ()
    end

    set_a_random_value(values_len=values_len - 1, values=values + 1, column=column)
    random_attributes_storage.write(column, values_len - 1, [values])

    return ()
end
