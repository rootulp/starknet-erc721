%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.Exercises.Exercise_2 import (
    ex2a_get_animal_rank_internal, ex2b_test_declare_animal_internal)
from contracts.IExerciceSolution import IExerciceSolution
from contracts.token.ERC721.IERC721 import IERC721
from contracts.utils.Exercises_utils import get_user_address_exercice_and_evaluator
from contracts.utils.ex00_base import has_validated_exercise, validate_exercice, distribute_points
from contracts.storage import assigned_legs_number, assigned_wings_number, assigned_sex_number

# Create a function that allows any breeder to call your contract and declare a new animal
func ex3{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    # Checks if the evaluator can mint a NFT with the right characteristics

    let (caller_address, submited_exercise_address,
        evaluator_address) = get_user_address_exercice_and_evaluator()

    # Reading balance of evaluator in exercise
    let (evaluator_init_balance) = IERC721.balanceOf(
        contract_address=submited_exercise_address, owner=evaluator_address)

    # Requesting new attributes
    ex2a_get_animal_rank_internal(caller_address)

    # Retrieve expected characteristics
    let (expected_sex) = assigned_sex_number(caller_address)
    let (expected_legs) = assigned_legs_number(caller_address)
    let (expected_wings) = assigned_wings_number(caller_address)

    # Declaring a new animal with the desired parameters
    let (created_token) = IExerciceSolution.declare_animal(
        contract_address=submited_exercise_address,
        sex=expected_sex,
        legs=expected_legs,
        wings=expected_wings)

    # Checking that the animal was declared correctly. We basically reuse ex2 lol
    # If it wasn't done correctly, this should fail
    ex2b_test_declare_animal_internal(created_token)

    # Ok so if I got until here then... nothing failed. I get points
    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 3)

    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 3)
        # Sending points
        distribute_points(caller_address, 2)
    end
    return ()
end
