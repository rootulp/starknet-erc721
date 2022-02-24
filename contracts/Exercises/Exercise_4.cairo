%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub
from contracts.utils.ex00_base import has_validated_exercise, validate_exercice, distribute_points
from contracts.utils.Exercises_utils import get_user_address_exercice_and_evaluator, assert_uint_eq
from contracts.token.ERC721.IERC721 import IERC721
from contracts.IExerciceSolution import IExerciceSolution

func ex4{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Checks if the evaluator can burn a NFT
    alloc_locals

    let (caller_address, submited_exercise_address,
        evaluator_address) = get_user_address_exercice_and_evaluator()

    # Getting initial token balance. Must be at least 1
    let (evaluator_init_balance) = IERC721.balanceOf(
        contract_address=submited_exercise_address, owner=evaluator_address)

    # Getting an animal id of Evaluator. tokenOfOwnerByIndex should return the list of NFTs owned by and address
    let (token_id) = IExerciceSolution.token_of_owner_by_index(
        contract_address=submited_exercise_address, account=evaluator_address, index=0)

    # Declaring it as dead
    IExerciceSolution.declare_dead_animal(
        contract_address=submited_exercise_address, token_id=token_id)

    # Checking end balance
    let (evaluator_end_balance) = IERC721.balanceOf(
        contract_address=submited_exercise_address, owner=evaluator_address)

    # I need value 1 in the uint format to be able to substract it, and add it, to compare balances
    let one_as_uint256 : Uint256 = Uint256(1, 0)
    # Store expected balance in a variable, since I can't use everything on a single line
    let evaluator_expected_balance : Uint256 = uint256_sub(evaluator_init_balance, one_as_uint256)
    # Verifying that balances where updated correctly
    assert_uint_eq(evaluator_expected_balance, evaluator_end_balance, 1)

    # Check that properties are deleted
    # Reading animal characteristic in player solution
    let (read_sex, read_legs, read_wings) = IExerciceSolution.get_animal_characteristics(
        contract_address=submited_exercise_address, token_id=token_id)
    # Checking characteristics are correct
    assert read_sex + read_legs + read_wings = 0

    # TODO Testing killing another person's animal. The caller has to hold an animal
    # Requires try / catch, or something smarter. I'll think about it.

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 4)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 4)
        # Sending points
        distribute_points(caller_address, 2)
    end
    return ()
end
