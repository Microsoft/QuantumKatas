from pytest import approx

tests = {}


# Exercise decorator, specifying that this function needs to be tested
def exercise(fun):
    tests[fun.__name__](fun)
    return fun


# Test decorator, specifying that this is a test for an exercise
def test(fun):
    tests[fun.__name__[:-5]] = fun
    return fun


# ------------------------------------------------------
# Checks that two matrices are (approximately) equal to each other
def matrix_equal(act, exp):
    if act == ... or exp == ...:
        return False

    h = len(act)
    w = len(act[0])
    # Check that sizes match
    if h != len(exp) or w != len(exp[0]):
        return False

    for i in range(h):
        # Check that the length of each row matches the expectation
        if w != len(act[i]):
            return False
        for j in range(w):
            if act[i][j] == ... or act[i][j] != approx(exp[i][j]):
                return False
    return True


# ------------------------------------------------------
def row_echelon_form_ref(A):
    m = len(A)
    n = m + 1

    for k in range(m):
        pivots = [abs(A[i][k]) for i in range(k, m)]
        i_max = pivots.index(max(pivots)) + k

        # Check for singular matrix
        assert A[i_max][k] != 0, "Matrix is singular!"

        # Swap rows
        A[k], A[i_max] = A[i_max], A[k]

        for i in range(k + 1, m):
            f = A[i][k] / A[k][k]
            for j in range(k + 1, n):
                A[i][j] -= A[k][j] * f

            # Fill lower triangular matrix with zeros:
            A[i][k] = 0
    return A


@test
def row_echelon_form_test(fun):
    M_1 = [[0, 1, 1], [1, 1, 1]]
    M_2 = [[0, 1, 1], [1, 1, 1]]

    expected = row_echelon_form_ref(M_1)
    # M has been mutated
    actual = fun(M_2)
    if actual is None:
        print("Your function must return a matrix!")
        return
    if not matrix_equal(actual, expected):
        print("Unexpected result. Try again!")
        return
    print("Success!")


# ------------------------------------------------------
def back_substitution_ref(A):
    # Solve equation Ax=b for an upper triangular matrix A
    x = []
    m = len(A)
    for i in range(m - 1, -1, -1):
        x.insert(0, A[i][m] / A[i][i])
        for k in range(i - 1, -1, -1):
            A[k][m] -= A[k][i] * x[0]
    return x


@test
def back_substitution_test(fun):
    N_1 = [[1, 1, 1], [0, 1, 1]]
    N_2 = [[1, 1, 1], [0, 1, 1]]

    expected = back_substitution_ref(N_1)
    # N has been mutated
    actual = fun(N_2)
    if actual is None:
        print("Your function must return a list!")
        return
    if actual != expected:
        print("Unexpected result. Try again!")
        return
    print("Success!")


# ------------------------------------------------------
def dot_product_ref(j, s):
    accum = 0
    for i in range(len(j)):
        accum += int(j[i]) * int(s[i])
    sol = accum % 2

    return sol


@test
def dot_product_test(fun):
    a_1 = [1, 1, 1]
    b_1 = [1, 0, 1]
    a_2 = [1, 1, 1]
    b_2 = [1, 0, 1]

    expected = dot_product_ref(a_1, b_1)
    actual = fun(a_2, b_2)
    if actual is None:
        print("Your function must return a value!")
        return
    if actual != expected:
        print("Unexpected result. Try again!")
        return
    print("Success!")


print("Success!")
