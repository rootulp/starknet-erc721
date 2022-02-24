%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.token.ERC721.IERC721 import IERC721
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from contracts.storage import player_exercise_solution_storage

func get_user_and_evaluator_balance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, contract_address : felt) -> (
        evaluator_balance : Uint256, user_balance : Uint256):
    # Returns the user's and the evaluator's balance
    let (evaluator_address) = get_contract_address()  # gets the evaluator address
    let (evaluator_balance) = IERC721.balanceOf(
        contract_address=contract_address, owner=evaluator_address)  # gets the evaluator's balance

    let (user_balance) = IERC721.balanceOf(contract_address=contract_address, owner=user_address)  # gets the user's balance

    return (evaluator_balance, user_balance)
end

func get_user_address_exercice_and_evaluator{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        caller_address : felt, exercice : felt, evaluator : felt):
    # Returns the caller address, his submited exercise address and the evaluator's address
    let (caller_address) = get_caller_address()  # gets the caller address
    let (exercice) = player_exercise_solution_storage.read(caller_address)  # gets the submited exercise address
    let (evaluator) = get_contract_address()  # gets the evaluator's address
    return (caller_address, exercice, evaluator)
end

func assert_uint_eq{range_check_ptr}(first : Uint256, last : Uint256, is_valid : felt):
    let (is_uint_eq) = uint256_eq(first, last)
    assert is_uint_eq = is_valid
    return ()
end
