%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.storage import (
    assigned_rank_storage, max_rank_storage, next_rank_storage, assigned_legs_number,
    assigned_wings_number, assigned_sex_number)
from contracts.utils.Exercises_utils import get_user_address_exercice_and_evaluator
from contracts.IExerciceSolution import IExerciceSolution
from contracts.utils.ex00_base import distribute_points, has_validated_exercise, validate_exercice

func ex2a_get_animal_rank_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(caller_address : felt):
    # Assigns an animal rank to a user
    alloc_locals

    # Reading next available slot
    let (next_rank) = next_rank_storage.read()
    # Assigning to user
    assigned_rank_storage.write(caller_address, next_rank)

    let new_next_rank = next_rank + 1
    let (max_rank) = max_rank_storage.read()

    # Checking if we reach max_rank
    if new_next_rank == max_rank:
        next_rank_storage.write(0)
    else:
        next_rank_storage.write(new_next_rank)
    end
    return ()
end

func ex2b_test_declare_animal_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token_id : Uint256):
    alloc_locals
    let (caller_address, submited_exercise_address,
        evaluator_address) = get_user_address_exercice_and_evaluator()
    # Checks that the specifed NFT has the right characteristic

    # ========= Retrieve expected characteristics =========
    let (expected_sex) = assigned_sex_number(caller_address)
    let (expected_legs) = assigned_legs_number(caller_address)
    let (expected_wings) = assigned_wings_number(caller_address)

    # Reading animal characteristic in player solution
    let (read_sex, read_legs, read_wings) = IExerciceSolution.get_animal_characteristics(
        contract_address=submited_exercise_address, token_id=token_id)
    # Checking characteristics are correct
    assert read_sex = expected_sex
    assert read_legs = expected_legs
    assert read_wings = expected_wings

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 2)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 2)
        # Sending points
        distribute_points(caller_address, 2)
    end
    return ()
end
