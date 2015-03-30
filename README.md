This is a little Haskell program to illustrate the costly
state verification problem in financial economics.

## The Economic Problem

A project run by an entrepreneur can yield a revenue of 0,
2, 4, 6 or 8; each with probabilty 1/5. The entrepreneur
borrows money from an investor and writes a contract
describing the terms of repayment. There is asymmetric
information in the form of costly state verification: once
the project is completed the actual revenue received is
known only to the entreprenuer and not to the investor.  If
the investor wants to find out the actual revenue, she has
to run an audit which costs her 1 unit of output.

The contract between the entrepreneur and investor
specifies, for each value of revenue, the payment to be made
to the investor and whether an audit is to be run. It is
expected that once the project is complete the entrepreneur
will announce a revenue. If the contract does not specify an
audit for that revenue level then the entrepreneur simply
pays the amount specified in that contract for that revenue
level. If the contract specifies an audit for that revenue
level then the investor pays 1 unit of output to carry out
the audit and then the entrepreneur has to make the payment
specified for the actual revenue earned (which is revealed
by the audit).

Both the entrepreneur and the investor are risk-neutral,
i.e. they care only about their expected earnings. For the
investor this is the earning net of any audit cost.

Our goal is to specify a contract which is
incentive-compatible --- the entrepreneur announces the
actual revenue earned --- and efficient --- there is no
other contract which can make one of the parties strictly
better off without making the other party worse off.

## The Program

The present program interactively accepts a contract
specification and reports whether it is feasible,
incentive-compatible and efficient or not. If it is not
incentive compatible it reports the conditions under which
the entrepreneur lies. If it is not efficient then the
program demonstrates another contract which makes the
entrepreneur better off without making the investor any
worse.

## An example session

````text
Incomes, p: [(0.0,0.2),(2.0,0.2),(4.0,0.2),(6.0,0.2),(8.0,0.2)].
Audit cost: 1.0

Enter entrepreneur's payment for each state separated by commas
Put a '*' after a payment to denote a verified state.
For eg: 0*,2*,4,4,4
The audit cost is payed by the investor.
Type 'q' to quit
````

### An infeasible contract

````text
> 0*,3*,4,5,6
Invalid: Claim greater than income
````

### A contract which is not incentive compatible

````text
> 0*,0*,4,5,6
Untruthful: 6.0 -> 4.0, 8.0 -> 4.0
````

The entrepreneur has an incentive to announce a revenue of 4.0 when
her true revenue is 6.0 or 8.0.

### An inefficient contract
````text
> 0*,0*,0*,4*,5
Inefficient
Your contract pays Ent=2.20, Inv=1.00
Try: 0.00*,1.50,1.50,1.50,1.50
which pays Ent=2.80, Inv=1.00
````

A Pareto superior contract is printed out as evidence of inefficiency.

### An efficient contract

````text
> 0*,2*,3,3,3
Your contract is efficient
````

## References

I wrote this program to demonstrate the issues in Section
9.9 of Romer's *Advanced Macroeconomics*. Warning: the
characterization of contracts in the discrete case
demonstrated by the program is slightly different from the
continuous case discussed in Romer.

