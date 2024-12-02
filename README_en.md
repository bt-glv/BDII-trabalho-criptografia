> Cotemig: Database II  
> Prof. Gilberto Assis  
> PL/SQL Assignment  

# Rules for the PL/SQL Assignment

</br>

## 1. Group Formation
- The assignment will be carried out in groups of up to **3 students**.
  - **Note**: For each additional student in the group, there will be a **-30% penalty on the grade**.
  
</br>

## 2. Assignment Value
- The assignment is worth **30 points**.

</br>

## 3. Submission Date
- The submission date for **ALL groups** will be **17/11/2022**.
  - **Note**: For each day of late submission, **50% of the grade will be deducted**.

</br>

## 4. Submission Method
- The assignment must be submitted via **CLASSROOM**.

</br>

## 5. Assignment Description
The assignment involves creating routines responsible for encrypting and decrypting the values stored in the **PASSWORD** field of the **LOGIN** table.

### Data Model
The group must follow the data model provided and create the corresponding objects.

### Business Rules

#### 1. Function `FN_CRIPTOGRAFIA()`
- Must accept the following parameters:
  - `PASSWORD`: the password to be encrypted.
  - `INCREMENT`: the value used following the encryption rule described below.

#### 2. Encryption Rule
Encryption will be carried out in 3 steps:

1. The function should shuffle the password characters using a **3xN matrix**.
   - Example: If the password is `COTEMIG123`, the shuffled result would be:
     ```
     C O T
     E M I
     G 1 2
     3
     ```

2. Characters must be converted to their **ASCII** table equivalent.
   - **Note**: Ensure all numbers have 3 positions.

3. Shuffle the password characters using a 3xN matrix. For example:

CEG3 OM1 TI2

Becomes:

CEG3OM1TI2


4. Convert characters to their ASCII equivalents:
- `CEG3OM1TI2 -> 070072074054082080052087076053`
- **Note**: All numbers must have 3 positions.

5. Add the value of `INCREMENT` to each generated number.
- Example: Assuming `INCREMENT` is **3**, the result would be:
  ```
  [067069071051079077049084073050]
  ```

This number will be recorded in the **PASSWORD** field of the **LOGIN** table for the respective user.

#### 3. Function `FN_DESCRIPTOGRAFIA()`
- Must accept the following parameters:
- `PASSWORD`: the encrypted password.
- `INCREMENT`: the increment value.
- Must reverse the encryption process described in item 2.

#### 4. Procedure `PR_INSERE_LOGIN()`
- Must accept the following parameters:
- `USER_ID`
- `LOGIN`
- `PASSWORD`

The procedure must:

1. Ensure there are no duplicate values for `USER_ID` and `LOGIN`.
2. Use the `FN_CRIPTOGRAFIA()` function to shuffle the password provided by the user.
- **Tip**:
  - Create a variable to store the timestamp of the insert:
    ```sql
    TIMESTAMP TIME_OF_INSERT;
    TIME_OF_INSERT := SYSTIMESTAMP;
    ```
  - Use the following command as the value for the `INCREMENT` parameter:
    ```sql
    to_char(TIME_OF_INSERT, 'FF1')
    ```
3. Insert the login into the **LOGIN** table.
4. Insert the access information into the **ACCESS** table, using the same `TIME_OF_INSERT` value.

#### 5. Procedure `PR_VALIDA_LOGIN()`
- Must accept the following parameters:
- `LOGIN`
- `PASSWORD`

The procedure must:

1. Verify that the `LOGIN` exists in the **LOGIN** table.
2. Use the `FN_DESCRIPTOGRAFIA()` function to decrypt the password provided by the user.
- **Tip**:
  - The `INCREMENT` value should be retrieved from the `TIMESTAMP` field in the **ACCESS** table corresponding to the `LOGIN` provided.
3. If the passwords match:
1. Update the `PASSWORD` field in the **LOGIN** table with a new `INCREMENT` value (current timestamp).
2. Update the `TIMESTAMP` field in the **ACCESS** table with the same value used for the `INCREMENT`.
4. Emit an appropriate message.
