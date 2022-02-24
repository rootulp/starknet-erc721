%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub
from starkware.starknet.common.syscalls import get_caller_address

from contracts.utils.ex00_base import has_validated_exercise, validate_exercice, distribute_points
from contracts.utils.Exercises_utils import assert_uint_eq, get_user_address_exercice_and_evaluator
from contracts.storage import dummy_token_address_storage, has_been_paired
from contracts.token.ERC20.IERC20 import IERC20
from contracts.IExerciceSolution import IExerciceSolution

func ex5a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Checks that you own DummyTokens
    alloc_locals
    # Reading caller address
    let (caller_address) = get_caller_address()
    # Reading sender balance in dummy token
    let (dummy_token_address) = dummy_token_address_storage.read()
    let (dummy_token_init_balance) = IERC20.balanceOf(
        contract_address=dummy_token_address, account=caller_address)

    # Verifying it's not 0
    # Instanciating a zero in uint format
    let zero_as_uint256 : Uint256 = Uint256(0, 0)
    assert_uint_eq(dummy_token_init_balance, zero_as_uint256, 0)

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 51)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 51)
        # Sending points
        distribute_points(caller_address, 2)
    end
    return ()
end

func ex5b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Checks that the evaluator can register himself as a breeder
    alloc_locals
    let (caller_address, submited_exercise_address,
        evaluator_address) = get_user_address_exercice_and_evaluator()

    # Is evaluator currently a breeder?
    let (is_evaluator_breeder_init) = IExerciceSolution.is_breeder(
        contract_address=submited_exercise_address, account=evaluator_address)
    assert is_evaluator_breeder_init = 0
    # TODO test that evaluator can not yet declare an animal (requires try/catch)

    # Reading registration price. Registration is payable in dummy token
    let (registration_price) = IExerciceSolution.registration_price(
        contract_address=submited_exercise_address)
    # Reading evaluator balance in dummy token
    let (dummy_token_address) = dummy_token_address_storage.read()
    let (dummy_token_init_balance) = IERC20.balanceOf(
        contract_address=dummy_token_address, account=evaluator_address)
    # Approve the exercice for spending my dummy tokens
    IERC20.approve(
        contract_address=dummy_token_address,
        spender=submited_exercise_address,
        amount=registration_price)

    # Require breeder permission.
    IExerciceSolution.register_me_as_breeder(contract_address=submited_exercise_address)

    # Check that I am indeed a breeder
    let (is_evaluator_breeder_end) = IExerciceSolution.is_breeder(
        contract_address=submited_exercise_address, account=evaluator_address)
    assert is_evaluator_breeder_end = 1

    # Check that my balance has been updated
    let (dummy_token_end_balance) = IERC20.balanceOf(
        contract_address=dummy_token_address, account=evaluator_address)
    # Store expected balance in a variable, since I can't use everything on a single line
    let evaluator_expected_balance : Uint256 = uint256_sub(
        dummy_token_init_balance, registration_price)

    # Verifying that balances where updated correctly
    assert_uint_eq(evaluator_expected_balance, dummy_token_end_balance, 1)

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(caller_address, 52)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercice(caller_address, 52)
        # Sending points
        distribute_points(caller_address, 2)
    end
    return ()
end
