%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub

from contracts.utils.ex00_base import distribute_points, has_validated_exercise, validate_exercice
from contracts.token.ERC721.IERC721 import IERC721
from contracts.utils.Exercises_utils import (
    get_user_and_evaluator_balance, get_user_address_exercice_and_evaluator, assert_uint_eq)

##############
##############
# # INTERNAL ##
##############
##############

func assert_token_ownership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        contract_address : felt, token_id : Uint256, expected_owner : felt):
    # Verifies that the given token belongs to the expected address
    let (token_owner) = IERC721.ownerOf(contract_address=contract_address, token_id=token_id)  # gets the owner of the token
    assert expected_owner = token_owner  # asserts that the owner is the expected owner
    return ()
end

################
################
# # EXERCISE 1 ##
################
################

func ex1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Checks that the evaluator contract owns the NFT number 1 from the caller's submited exercise
    # Allocating locals. Make your code easier to write and read by avoiding some revoked references
    alloc_locals
    # Creating the token id
    let token_id : Uint256 = Uint256(1, 0)

    let (caller_address, exercice, evaluator_address) = get_user_address_exercice_and_evaluator()

    # ========= Verifying that the token 1 belongs to the evaluator =========
    assert_token_ownership(
        contract_address=exercice, token_id=token_id, expected_owner=evaluator_address)

    # ========= Verifying that the token is transferable =========

    # Reading initial balance of evaluator and caller
    let (evaluator_init_balance, caller_init_balance) = get_user_and_evaluator_balance(
        caller_address, exercice)

    let zero_as_uint256 : Uint256 = Uint256(0, 0)
    # equivalent of (evaluator_init_balance == 0) == False
    assert_uint_eq(evaluator_init_balance, zero_as_uint256, 0)

    # Check that token 1 can be transferred back to msg.sender
    IERC721.transferFrom(
        contract_address=exercice, _from=evaluator_address, to=caller_address, token_id=token_id)

    # Verifying that the token 1 belongs to the sender
    assert_token_ownership(
        contract_address=exercice, token_id=token_id, expected_owner=caller_address)

    # Reading balance of msg sender after transfer
    let (evaluator_end_balance, sender_end_balance) = get_user_and_evaluator_balance(
        caller_address, exercice)

    let one_as_uint256 : Uint256 = Uint256(1, 0)
    # Store expected balance in a variable, since I can't use everything on a single line
    let evaluator_expected_balance : Uint256 = uint256_sub(evaluator_init_balance, one_as_uint256)
    let sender_expected_balance : Uint256 = uint256_add(caller_init_balance, one_as_uint256)

    # Verifying that balances where updated correctly
    assert_uint_eq(sender_expected_balance, sender_end_balance, 1)
    assert_uint_eq(evaluator_expected_balance, evaluator_end_balance, 1)

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 1)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr
    # ========= Credit points to the caller =========
    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 1)
        # Sending points
        distribute_points(caller_address, 2)
    end
    return ()
end
