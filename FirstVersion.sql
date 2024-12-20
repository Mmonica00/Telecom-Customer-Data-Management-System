﻿Create database Telecom_Team_14;
USE Telecom_Team_14;

Go
---------------------------------------- 2.1a -------------------------------------
CREATE PROC createAllTables
As
	Create table Customer_profile 
		(nationalID int , 
		first_name Varchar(50), 
		last_name Varchar(50), 
		email Varchar(50), 
		address Varchar(50), 
		date_of_birth date 
		PRIMARY KEY (nationalID) 
	);


	Create table Customer_Account (
		mobileNo char(11), 
		pass varchar(50),
		balance decimal(10,1),
		account_type Varchar(50), 
		start_date date, 
		status Varchar(50), 
		point int default 0, 
		nationalID int,
		PRIMARY KEY (mobileno),
		FOREIGN KEY (nationalID) REFERENCES Customer_Profile ON DELETE CASCADE ON UPDATE CASCADE,
		CHECK(account_type in ('Post_Paid', 'Pre_Paid', 'Pay_As_You_Go')),
		CHECK(status in ('Active', 'OnHold'))
	);


	Create Table Service_Plan (
		planID int identity(1,1), 
		SMS_offered int, 
		minutes_offered int, 
		data_offered int, 
		name Varchar(50), 
		price int, 
		description Varchar(50),
		PRIMARY KEY(planID)
	);


	Create Table Subscription (
		mobileNo char(11), 
		planID int, 
		subscription_date date,
		status Varchar(50),
		PRIMARY KEY(mobileNo, planID),
		FOREIGN KEY (mobileNo) REFERENCES Customer_Account ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY (planID) REFERENCES Service_Plan ON DELETE CASCADE ON UPDATE CASCADE,
		CHECK(status in ('Active', 'OnHold'))
	);


	Create Table Plan_Usage (
		usageID int identity(1,1), 
		start_date date, 
		end_date date, 
		data_consumption int,
		minutes_used int, 
		SMS_sent int, 
		mobileNo char(11), 
		planID int 
		PRIMARY KEY (usageID),
		FOREIGN KEY (mobileNo) REFERENCES Customer_Account ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY (planID) REFERENCES Service_Plan ON DELETE CASCADE ON UPDATE CASCADE
	);


	Create Table Payment (
		paymentID int identity(1,1), 
		amount decimal (10,1), 
		date_of_payment date, 
		payment_method Varchar(50), 
		status Varchar(50), 
		mobileNo char(11),
		PRIMARY KEY (paymentID),
		FOREIGN KEY (mobileNo) REFERENCES Customer_Account ON DELETE CASCADE ON UPDATE CASCADE,
		CHECK(payment_method in ('Cash', 'Credit')),
		CHECK(status in ('Successful', 'Pending', 'Rejected'))
	);


	Create Table Process_Payment (
		paymentID int, 
		planID int, 
		remaining_balance DECIMAL(10,1), --As trigger calculation
		extra_amount DECIMAL(10,1), --As trigger calculation
		PRIMARY KEY (paymentID),
		FOREIGN KEY (paymentID) REFERENCES Payment ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY (planID) REFERENCES Service_Plan ON DELETE CASCADE ON UPDATE CASCADE
	);
	


	Create Table Wallet (
		walletID int identity(1,1), 
		current_balance decimal(10,2), 
		currency Varchar(50), 
		last_modified_date date, 
		nationalID int,
		PRIMARY KEY (walletID),
		FOREIGN KEY (nationalID) REFERENCES Customer_profile(nationalID) ON DELETE CASCADE ON UPDATE CASCADE
	);


	Create Table Transfer_money (
		walletID1 int, 
		walletID2 int, 
		transfer_id int, 
		amount decimal(10,2),
		transfer_date date,
		PRIMARY KEY(walletID1,walletID2,transfer_id),
		FOREIGN KEY (walletID1) REFERENCES Wallet,
		FOREIGN KEY (walletID2) REFERENCES Wallet
	);


	Create Table Benefits (
		benefitID int identity(1,1), 
		description Varchar(50), 
		validity_date date, 
		status Varchar(50),
		mobileNo char(11),
		PRIMARY KEY (benefitID),
		FOREIGN KEY (mobileNo) REFERENCES Customer_Account ON DELETE CASCADE ON UPDATE CASCADE,
		CHECK(status in ('Active', 'Expired'))
	);


	Create Table Points_Group (
		pointID int identity(1,1), 
		benefitID int, 
		pointsAmount int, 
		PaymentID int,
		PRIMARY KEY(pointID,benefitID),
		FOREIGN KEY (benefitID) REFERENCES Benefits ,
		FOREIGN KEY (PaymentID) REFERENCES Payment 
	);


	Create Table Exclusive_Offer (
		offerID int identity(1,1), 
		benefitID int, 
		internet_offered int, 
		SMS_offered int,
		minutes_offered int,
		PRIMARY KEY(offerID,benefitID),
		FOREIGN KEY (benefitID) REFERENCES Benefits
	);


	Create Table Cashback (
		CashbackID int identity(1,1), 
		benefitID int, 
		walletID int, 
		amount int default 0, 
		credit_date date,
		PRIMARY KEY(CashbackID,benefitID),
		FOREIGN KEY (benefitID) REFERENCES Benefits,
		FOREIGN KEY (walletID) REFERENCES Wallet
		--Cashback as 10% from payment amount in 2.4M
	);


	Create Table Plan_Provides_Benefits (
		benefitID int, 
		planID int
		PRIMARY KEY(benefitID,planID),
		FOREIGN KEY (benefitID) REFERENCES Benefits,
		FOREIGN KEY (planID) REFERENCES Service_Plan ,
	);


	Create Table Shop (
		shopID int identity(1,1), 
		name varchar(50), 
		category varchar(50)
		PRIMARY KEY(shopID)
	);


	Create Table Physical_Shop (
		shopID int, 
		address varchar(50), 
		working_hours varchar(50),
		PRIMARY KEY(shopID),
		FOREIGN KEY (shopID) REFERENCES Shop ON DELETE CASCADE ON UPDATE CASCADE,
	);


	Create Table E_shop (
		shopID int, 
		URL varchar(50), 
		rating int
		PRIMARY KEY(shopID),
		FOREIGN KEY (shopID) REFERENCES Shop ON DELETE CASCADE ON UPDATE CASCADE,
	);


	Create Table Voucher (
		voucherID int identity(1,1), 
		value int, 
		expiry_date date, 
		points int, 
		mobileNo char(11),
		shopID int,
		redeem_date date,
		PRIMARY KEY(voucherID),
		FOREIGN KEY (mobileNo) REFERENCES Customer_Account ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY (shopID) REFERENCES Shop ON DELETE CASCADE ON UPDATE CASCADE
	);


	Create Table Technical_Support_Ticket (
		ticketID int identity(1,1), 
		mobileNo char(11), 
		Issue_description Varchar(50),
		priority_level int, 
		status Varchar(50),
		PRIMARY KEY(ticketID),
		FOREIGN KEY (mobileNo) REFERENCES Customer_Account ON DELETE CASCADE ON UPDATE CASCADE,
		CHECK(status in ('Open', 'InProgress', 'Resolved'))
	);
------------------------------------------------------------------------------------

GO

EXEC createAllTables;

GO

CREATE FUNCTION CalculateRemainingBalance (@paymentID INT, @planID INT)
RETURNS DECIMAL(10, 1)
AS
BEGIN
    DECLARE @remaining_balance DECIMAL(10, 1);
    DECLARE @paymentAmount DECIMAL(10, 1);
    DECLARE @servicePlanPrice DECIMAL(10, 1);

    SELECT @paymentAmount = P.amount
    FROM Payment P
    WHERE P.paymentID = @paymentID;

    SELECT @servicePlanPrice = SP.price
    FROM Service_Plan SP
    WHERE SP.planID = @planID;

    IF @paymentAmount < @servicePlanPrice
    BEGIN
        SET @remaining_balance = @servicePlanPrice - @paymentAmount;
    END
    ELSE
    BEGIN
        SET @remaining_balance = 0;
    END

    RETURN @remaining_balance;
END;
GO

CREATE FUNCTION CalculateExtraAmount (@paymentID INT, @planID INT)
RETURNS DECIMAL(10, 1)
AS
BEGIN
    DECLARE @extra_amount DECIMAL(10, 1);
    DECLARE @paymentAmount DECIMAL(10, 1);
    DECLARE @servicePlanPrice DECIMAL(10, 1);

    SELECT @paymentAmount = P.amount
    FROM Payment P
    WHERE P.paymentID = @paymentID;

    SELECT @servicePlanPrice = SP.price
    FROM Service_Plan SP
    WHERE SP.planID = @planID;

    IF @paymentAmount > @servicePlanPrice
    BEGIN
        SET @extra_amount = @paymentAmount - @servicePlanPrice;
    END
    ELSE
    BEGIN
        SET @extra_amount = 0;
    END

    RETURN @extra_amount;
END;
GO

CREATE TRIGGER CalculateRemainingBalanceAndExtraAmount
ON Process_Payment
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @paymentID INT;
    DECLARE @planID INT;
    DECLARE @remaining_balance DECIMAL(10, 1);
    DECLARE @extra_amount DECIMAL(10, 1);

    SELECT @paymentID = paymentID, @planID = planID
    FROM INSERTED;

    SET @remaining_balance = dbo.CalculateRemainingBalance(@paymentID, @planID);
    SET @extra_amount = dbo.CalculateExtraAmount(@paymentID, @planID);

    UPDATE Process_Payment
    SET 
        remaining_balance = @remaining_balance,
        extra_amount = @extra_amount
    WHERE paymentID = @paymentID;
END;
GO

CREATE VIEW ProcessPaymentView AS
SELECT 
    PP.paymentID,
    PP.planID,
    dbo.CalculateRemainingBalance(PP.paymentID, PP.planID) AS remaining_balance,
    dbo.CalculateExtraAmount(PP.paymentID, PP.planID) AS extra_amount
FROM 
    Process_Payment PP;
GO

---------------------------------------- 2.1c -------------------------------------
Create PROC dropAllTables
As

	DROP TABLE Technical_Support_Ticket;
	DROP TABLE Voucher;
	DROP TABLE E_shop;
	DROP TABLE Physical_Shop;
	DROP TABLE Shop;
	DROP TABLE Plan_Provides_Benefits;
	DROP TABLE Cashback;
	DROP TABLE Exclusive_Offer;
	DROP TABLE Points_Group;
	DROP TABLE Benefits;
	DROP TABLE Transfer_money;
	DROP TABLE Wallet;
	DROP TABLE Process_Payment;
	DROP TABLE Payment;
	DROP TABLE Plan_Usage;
	DROP TABLE Subscription;
	DROP TABLE Service_Plan;
	DROP TABLE Customer_Account;
	DROP TABLE Customer_profile;

------------------------------------------------------------------------------------

GO

EXEC dropAllTables;

GO

---------------------------------------- 2.1d -------------------------------------

Create PROC dropAllProceduresFunctionsViews 
As
    DROP VIEW IF EXISTS allCustomerAccounts;
    DROP VIEW IF EXISTS allServicePlans;
    DROP VIEW IF EXISTS allBenefits;
    DROP VIEW IF EXISTS AccountPayments;
    DROP VIEW IF EXISTS allShops;
    DROP VIEW IF EXISTS allResolvedTickets;
    DROP VIEW IF EXISTS CustomerWallet;
    DROP VIEW IF EXISTS E_shopVouchers;
    DROP VIEW IF EXISTS PhysicalStoreVouchers;
    DROP VIEW IF EXISTS Num_of_cashback;

    DROP FUNCTION IF EXISTS Account_Plan_date;
    DROP FUNCTION IF EXISTS Account_Usage_Plan;
    DROP FUNCTION IF EXISTS Account_SMS_Offers;
    DROP FUNCTION IF EXISTS Wallet_Cashback_Amount;
    DROP FUNCTION IF EXISTS Wallet_Transfer_Amount;
    DROP FUNCTION IF EXISTS Wallet_MobileNo;
    DROP FUNCTION IF EXISTS AccountLoginValidation;
    DROP FUNCTION IF EXISTS Consumption;
    DROP FUNCTION IF EXISTS Remaining_plan_amount;
    DROP FUNCTION IF EXISTS Extra_plan_amount;
    DROP FUNCTION IF EXISTS Subscribed_plans_5_Months;

    DROP PROCEDURE IF EXISTS createAllTables;
    DROP PROCEDURE IF EXISTS dropAllTables;
    DROP PROCEDURE IF EXISTS clearAllTables;
    DROP PROCEDURE IF EXISTS Account_Plan;
    DROP PROCEDURE IF EXISTS Benefits_Account;
    DROP PROCEDURE IF EXISTS Account_Payment_Points;
    DROP PROCEDURE IF EXISTS Total_Points_Account;
    DROP PROCEDURE IF EXISTS Unsubscribed_Plans;
    DROP PROCEDURE IF EXISTS Usage_Plan_CurrentMonth;
    DROP PROCEDURE IF EXISTS Cashback_Wallet_Customer;
    DROP PROCEDURE IF EXISTS Ticket_Account_Customer;
    DROP PROCEDURE IF EXISTS Account_Highest_Voucher;
    DROP PROCEDURE IF EXISTS Top_Successful_Payments;
    DROP PROCEDURE IF EXISTS Initiate_plan_payment;
    DROP PROCEDURE IF EXISTS Payment_wallet_cashback;
    DROP PROCEDURE IF EXISTS Initiate_balance_payment;
    DROP PROCEDURE IF EXISTS Redeem_voucher_points;


------------------------------------------------------------------------------------

GO

EXEC dropAllProceduresFunctionsViews;

GO

---------------------------------------- 2.1e -------------------------------------

Create PROC clearAllTables
As
	DELETE FROM Customer_profile;
	DELETE FROM Customer_Account;
	DELETE FROM Service_Plan;
	DELETE FROM Subscription;
	DELETE FROM Plan_Usage;
	DELETE FROM Payment;
	DELETE FROM Process_Payment;
	DELETE FROM Wallet;
	DELETE FROM Transfer_money;
	DELETE FROM Benefits;
	DELETE FROM Points_Group;
	DELETE FROM Exclusive_Offer;
	DELETE FROM Cashback;
	DELETE FROM Plan_Provides_Benefits;
	DELETE FROM Shop;
	DELETE FROM Physical_Shop;
	DELETE FROM E_shop;
	DELETE FROM Voucher;
	DELETE FROM Technical_Support_Ticket;

------------------------------------------------------------------------------------

GO

EXEC clearAllTables;

GO

---------------------------------------- 2.2 -------------------------------------

---------------------------------------- 2.2a -------------------------------------
CREATE VIEW allCustomerAccounts AS
SELECT 
	P.nationalID , 
	P.first_name, 
	P.last_name, 
	P.email, 
	P.address, 
	P.date_of_birth, 
	A.mobileNo AS Account_MobileNo, 
	A.pass AS Account_Password, 
	A.balance AS Account_Balance, 
	A.account_type, 
	A.start_date, 
	A.status AS Account_Status, 
	A.point AS Account_Points 
FROM Customer_profile P, Customer_Account A
WHERE status='Active' and A.nationalID = P.nationalID
GO

---------------------------------------- 2.2b -------------------------------------
CREATE VIEW allServicePlans AS
SELECT * 
FROM Service_Plan
GO

---------------------------------------- 2.2c -------------------------------------
CREATE VIEW allBenefits AS
SELECT *
FROM Benefits
WHERE status= 'Active'
GO

---------------------------------------- 2.2d -------------------------------------
CREATE VIEW AccountPayments AS
SELECT 
	P.paymentID, 
	P.amount AS Payment_Amount, 
	P.date_of_payment, 
	P.payment_method, 
	P.status AS Payment_Status, 
	P.mobileNo, 
	A.pass AS Account_Password, 
	A.balance AS Account_Balance, 
	A.account_type, 
	A.start_date, 
	A.status AS Account_Status, 
	A.point AS Account_Points 
FROM Payment P, Customer_Account A
WHERE P.mobileNo = A.mobileNo
GO

---------------------------------------- 2.2e -------------------------------------
CREATE VIEW All_Shops AS
SELECT 
    s.shopID,
    s.name AS shop_name,
    s.category AS shop_category,
    ps.address AS physical_address,
    ps.working_hours AS physical_working_hours,
    es.URL AS e_shop_url,
    es.rating AS e_shop_rating
FROM  Shop s LEFT JOIN  Physical_Shop ps ON s.shopID = ps.shopID LEFT JOIN  E_shop es ON s.shopID = es.shopID;
GO

---------------------------------------- 2.2f -------------------------------------
CREATE VIEW allResolvedTickets AS
SELECT*
FROM
    Technical_Support_Ticket
WHERE
    status = 'Resolved';
GO

---------------------------------------- 2.2g -------------------------------------

CREATE VIEW CustomerWallet AS
SELECT
    W.walletID,
    W.current_balance,
    W.currency,
    W.last_modified_date,
    CP.first_name,
    CP.last_name
FROM
    Wallet W
INNER JOIN
    Customer_profile CP ON W.nationalID = CP.nationalID;
GO


---------------------------------------- 2.2h -------------------------------------
CREATE VIEW E_shopVouchers AS
SELECT
    es.shopID,
    es.URL ,
    v.voucherID,
    v.value
FROM
    E_shop es
INNER JOIN
    Voucher v ON es.shopID = v.shopID
WHERE
    v.redeem_date IS NOT NULL;
GO

---------------------------------------- 2.2i -------------------------------------
CREATE VIEW PhysicalStoreVouchers AS
SELECT
    ps.shopID,
    ps.address,
    ps.working_hours,
    v.voucherID,
    v.value
FROM
    Physical_Shop ps
INNER JOIN
    Voucher v ON ps.shopID = v.shopID
WHERE
    v.redeem_date IS NOT NULL;
GO
---------------------------------------- 2.2j -------------------------------------
CREATE VIEW Num_of_cashback AS
SELECT
    w.walletID,
    COUNT(c.CashbackID) AS Number_Of_Cashbacks
FROM
    Wallet w
LEFT JOIN
    Cashback c ON w.walletID = c.walletID
GROUP BY
    w.walletID;
GO
---------------------------------------- 2.3 ---------------------------------------

---------------------------------------- 2.3a -------------------------------------
Create PROC Account_Plan
As
BEGIN 
	Select CA.*,SP.*
	From Customer_Account CA INNER JOIN Subscription S on CA.mobileNo = S.mobileNo 
		INNER JOIN Service_Plan SP on S.planID=SP.planID 
	Order by CA.mobileNo;
END
-----------------------------------------------------------------------------------

GO

EXEC Account_Plan;

GO

---------------------------------------- 2.3b -------------------------------------

Create Function Account_Plan_date(
	@Subscription_Date date ,
	@Plan_id int
)
returns Table 
As
RETURN (
	Select CA.mobileNo AS Mobile_Number, 
			SP.planID AS Plan_ID, 
			SP.name AS Plan_Name
	From Customer_Account CA 
		INNER JOIN Subscription S on CA.mobileNo = S.mobileNo 
		INNER JOIN Service_Plan SP on S.planID=SP.planID 
	Where S.subscription_date = @Subscription_Date AND S.planID = @Plan_id
); 
GO

---------------------------------------- 2.3c -------------------------------------
Create Function Account_Usage_Plan(
	@MobileNo char(11),
	@from_date date
)
returns table 
As
RETURN (
	Select U.planID, 
		SUM(U.data_consumption) AS Total_Data_Consumed,
        SUM(U.minutes_used) AS Total_Minutes_Used,
        SUM(U.SMS_sent) AS Total_SMS
	From Plan_Usage U
	Where U.mobileNo = @MobileNo AND U.start_date >= @from_date
	GROUP BY U.planID
);
GO

---------------------------------------- 2.3d -------------------------------------
CREATE PROCEDURE Benefits_Account
    @MobileNo CHAR(11),
    @PlanID INT
AS
BEGIN
    CREATE TABLE #DeletedBenefits (
        benefitID INT,
        description VARCHAR(50),
        validity_date DATE,
        status VARCHAR(50)
    );

    INSERT INTO #DeletedBenefits (benefitID, description, validity_date, status)
		SELECT b.benefitID, b.description, b.validity_date, b.status
		FROM Benefits b
		INNER JOIN Plan_Provides_Benefits ppb ON b.benefitID = ppb.benefitID
		INNER JOIN Service_Plan sp ON ppb.planID = sp.planID
		WHERE b.mobileNo = @MobileNo AND ppb.planID = @PlanID;

    DELETE FROM Benefits
    WHERE mobileNo = @MobileNo
    AND benefitID IN (
        SELECT benefitID
        FROM Plan_Provides_Benefits
        WHERE planID = @PlanID
    );

    SELECT * FROM #DeletedBenefits;
    DROP TABLE #DeletedBenefits;
END;
GO

---------------------------------------- 2.3e -------------------------------------
CREATE FUNCTION Account_SMS_Offers(
	@MobileNo CHAR(11)
)
RETURNS TABLE
AS
RETURN
(
    SELECT eo.offerID, eo.SMS_offered, eo.internet_offered, eo.minutes_offered, b.description
    FROM Exclusive_Offer eo INNER JOIN Benefits b ON eo.benefitID = b.benefitID
    WHERE b.mobileNo = @MobileNo
    AND eo.SMS_offered > 0 
);
GO

---------------------------------------- 2.3f -------------------------------------
CREATE PROCEDURE Account_Payment_Points
    @MobileNo CHAR(11)
AS
BEGIN
    DECLARE @TotalTransactions INT;
    DECLARE @TotalPoints INT;

    SELECT @TotalTransactions = COUNT(*)
    FROM Payment p INNER JOIN Customer_Account ca ON p.mobileNo = ca.mobileNo
    WHERE p.mobileNo = @MobileNo AND p.status = 'successful'
    AND p.date_of_payment >= DATEADD(YEAR, -1, GETDATE());

    SELECT @TotalPoints = SUM(pg.pointsAmount) 
    FROM Points_Group pg, Payment p
    WHERE p.mobileNo = @MobileNo and p.paymentID = pg.PaymentID and p.date_of_payment >= DATEADD(YEAR, -1, GETDATE()) ;

    SELECT @TotalTransactions AS Total_Transactions, @TotalPoints AS Total_Points;
END;
GO

---------------------------------------- 2.3g -------------------------------------
CREATE FUNCTION Wallet_Cashback_Amount(
	@WalletId int, 
	@planId int
)
returns int 
AS
BEGIN
    DECLARE @CashbackAmount int;

    SELECT @CashbackAmount = SUM(c.amount)
    FROM Cashback c
    INNER JOIN Benefits b ON c.benefitID = b.benefitID
    INNER JOIN Plan_Provides_Benefits ppb ON b.benefitID = ppb.benefitID
    WHERE c.walletID = @WalletId
    AND ppb.planID = @PlanId; 

    RETURN ISNULL(@CashbackAmount, 0);
END;
GO

---------------------------------------- 2.3h -------------------------------------
CREATE FUNCTION Wallet_Transfer_Amount (
	@Wallet_id int, 
	@start_date date, 
	@end_date date
)
returns Decimal(10,2)
AS
BEGIN 
	Declare @AvgAmount Decimal(10,2);

	SELECT @AvgAmount = AVG(t.amount)
    FROM Transfer_money t
    WHERE t.walletID1 = @Wallet_id
    AND t.transfer_date BETWEEN @Start_date AND @End_date;

    RETURN ISNULL(@AvgAmount, 0);

END;
GO

---------------------------------------- 2.3i -------------------------------------
CREATE FUNCTION Wallet_MobileNo(@MobileNo char(11))
RETURNS BIT
AS BEGIN
	DECLARE @IsThisNumberLinked BIT;
	IF EXISTS (
		SELECT *
		FROM Customer_Account CA , Wallet W
		WHERE CA.nationalID = W.nationalID AND CA.mobileNo=@MobileNo
	)
	BEGIN 
		SET @IsThisNumberLinked = 1;
	END
	ELSE
	BEGIN
		SET @IsThisNumberLinked = 0;
	END
	RETURN @IsThisNumberLinked;
END;
GO

---------------------------------------- 2.3j -------------------------------------
CREATE PROCEDURE Total_Points_Account
@MobileNo char(11)
AS
BEGIN
	UPDATE Customer_Account 
	SET point = (SELECT SUM(PG.pointsAmount) AS TotalPointsAmount
	FROM Benefits B, Points_Group PG, Customer_Account CA
	WHERE B.mobileNo = CA.mobileNo AND B.benefitID = PG.benefitID AND CA.mobileNo = @MobileNo)
	WHERE mobileNo = @MobileNo
END;
GO
---------------------------------------- 2.4 -------------------------------------
---------------------------------------- 2.4a -------------------------------------
CREATE FUNCTION AccountLoginValidation(
@MobileNo char(11),
@password varchar(50)
)
RETURNS BIT
AS BEGIN
	DECLARE @Success BIT;
	IF EXISTS (
		SELECT *
		FROM Customer_Account CA 
		WHERE CA.mobileNo=@MobileNo AND CA.pass=@password
	)
	BEGIN 
		SET @Success = 1;
	END
	ELSE
	BEGIN
		SET @Success = 0;
	END
	RETURN @Success;
END;
GO

---------------------------------------- 2.4b -------------------------------------
CREATE FUNCTION Consumption(
@Plan_name varchar(50), 
@start_date date,
@end_date date
)
RETURNS TABLE
AS 
RETURN(
	SELECT SUM(PU.data_consumption) AS Data_Consumption, SUM(PU.minutes_used) AS Minutes_Used, SUM(PU.SMS_sent) AS SMS_Sent
	FROM Plan_Usage PU, Service_Plan SP
	WHERE PU.planId = SP.planId
		AND SP.name = @plan_name
		AND PU.start_date >= @start_date              
        AND PU.end_date <= @end_date                    
)
GO

---------------------------------------- 2.4c -------------------------------------
CREATE PROCEDURE Unsubscribed_Plans
@MobileNo CHAR(11)
AS
BEGIN
	SELECT SP.name AS plan_name 
	FROM Service_Plan SP LEFT JOIN Subscription S ON SP.planId = S.planId AND S.mobileNo = @MobileNo
	WHERE s.mobileNo IS NULL;
END;
GO

---------------------------------------- 2.4d -------------------------------------
CREATE FUNCTION Usage_Plan_CurrentMonth(@MobileNo char(11))
RETURNS TABLE
AS 
RETURN(
	SELECT PU.planID, 
		SUM(pu.data_consumption) AS Data_consumption,   
        SUM(pu.minutes_used) AS Minutes_used,          
        SUM(pu.SMS_sent) AS SMS_sent
	FROM Plan_Usage PU, Subscription S
	WHERE PU.mobileNo = S.mobileNo 
		AND PU.planID = S.planID
		AND S.mobileNo = @MobileNo
		AND S.status = 'Active'
		AND MONTH(PU.start_date) = MONTH(CURRENT_TIMESTAMP)
		AND MONTH(PU.end_date) = MONTH(CURRENT_TIMESTAMP)
	GROUP BY PU.planId
)
GO

---------------------------------------- 2.4e -------------------------------------
CREATE FUNCTION Cashback_Wallet_Customer(@NationalID int)
RETURNS TABLE
AS
RETURN(
	SELECT CB.CashbackID, CB.amount AS Cashback_Amount, CB.credit_date
	FROM Cashback CB, Wallet W
	WHERE CB.walletID = W.walletID
		AND W.nationalID = @NationalID
)
GO

---------------------------------------- 2.4f -------------------------------------
CREATE PROCEDURE Ticket_Account_Customer
@NationalID int,
@Unresolved_Tickets int OUTPUT
AS
BEGIN
	SELECT @Unresolved_Tickets = COUNT(TST.ticketID)
	FROM Customer_Account CA, Technical_Support_Ticket TST
	WHERE CA.mobileNo = TST.mobileNo 
		AND CA.nationalID = @NationalID
		AND TST.status <> 'Resolved'
END;

GO
---------------------------------------- 2.4g -------------------------------------
CREATE PROCEDURE Account_Highest_Voucher 
@MobileNo CHAR(11),
@Voucher_id int OUTPUT
AS 
BEGIN 
	SELECT voucherID 
	FROM Voucher
	WHERE mobileNo = @MobileNo and value > All(SELECT value 
												FROM Voucher
												where mobileNo = @MobileNo)
END;

GO
---------------------------------------- 2.4h -------------------------------------
CREATE FUNCTION Remaining_plan_amount(@MobileNo char(11), @plan_name varchar(50))
RETURNS DECIMAL(10,1) 
AS
BEGIN
RETURN(
	SELECT PP.remaining_balance
	FROM Process_Payment PP, Payment P, Service_Plan S
	WHERE S.name = @plan_name and PP.planID = S.planID and P.paymentID = PP.paymentID and P.mobileNo = @MobileNo
)
END;
GO
---------------------------------------- 2.4i -------------------------------------
CREATE FUNCTION Extra_plan_amount(@MobileNo char(11), @plan_name varchar(50))
RETURNS DECIMAL(10,1) 
AS
BEGIN
RETURN(
	SELECT PP.extra_amount
	FROM Process_Payment PP, Payment P, Service_Plan S
	WHERE S.name = @plan_name and PP.planID = S.planID and P.paymentID = PP.paymentID and P.mobileNo = @MobileNo
)
END;
GO

---------------------------------------- 2.4j -------------------------------------
CREATE PROCEDURE Top_Successful_Payments 
@MobileNo char(11)
AS 
BEGIN 
	SELECT TOP 10 paymentID, mobileNo, amount, status, date_of_payment
	FROM Payment
	WHERE mobileNo = @MobileNo and status = 'Successful'
	ORDER BY amount DESC
END;

GO
---------------------------------------- 2.4k -------------------------------------
CREATE FUNCTION Subscribed_plans_5_Months(@MobileNo char(11))
RETURNS TABLE
AS 
RETURN(
	SELECT P.name
	FROM Subscription S, Service_Plan P 
	WHERE S.mobileNo = @MobileNo and S.planID = P.planID and DATEDIFF(MONTH, S.subscription_date, GETDATE()) <= 5 
);
GO
---------------------------------------- 2.4l -------------------------------------
CREATE PROCEDURE Initiate_plan_payment
@MobileNo char(11),
@amount decimal(10,1),
@payment_method varchar(50),
@plan_id int
AS
BEGIN
	INSERT INTO Payment VALUES(@amount,CURRENT_TIMESTAMP,@payment_method,'Successful',@MobileNo)
	UPDATE Subscription 
	SET status = 'Active' WHERE mobileNo = @MobileNo and planID = @plan_id
END

GO
---------------------------------------- 2.4m -------------------------------------

CREATE PROCEDURE Payment_wallet_cashback 
@MobileNo char(11),
@payment_id int,
@benefit_id int
AS 
BEGIN 
	DECLARE @cashback_calculation DECIMAL(10,2);
	DECLARE @current_balance DECIMAL(10,2);
	DECLARE @Wallet_id int;
	SET @cashback_calculation = 0.1 * (SELECT amount
										FROM Payment 
										WHERE mobileNo = @MobileNo and paymentID = @payment_id);
	SET @Wallet_id = (SELECT walletID
					FROM Wallet
					WHERE nationalID = (SELECT nationalID FROM Customer_Account WHERE mobileNo = @MobileNo) )

	SET @current_balance = @cashback_calculation + (SELECT current_balance 
														FROM Wallet
														WHERE walletID = @Wallet_id)
	UPDATE Wallet
	SET current_balance = @current_balance WHERE walletID = @Wallet_id
	INSERT INTO Cashback VALUES(@benefit_id,@Wallet_id,@cashback_calculation,CURRENT_TIMESTAMP)
END;
GO
---------------------------------------- 2.4n -------------------------------------
CREATE PROCEDURE Initiate_balance_payment
@MobileNo char(11) ,
@amount decimal(10,1), 
@payment_method varchar(50)
AS
BEGIN 
	DECLARE @Wallet_id int;
	INSERT INTO Payment Values(@amount,CURRENT_TIMESTAMP,@payment_method,'Successful',@MobileNo)
	SET @Wallet_id = (SELECT walletID
					FROM Wallet
					WHERE nationalID = (SELECT nationalID FROM Customer_Account WHERE mobileNo = @MobileNo) )
	UPDATE Wallet
	SET current_balance = current_balance + @amount, last_modified_date = CURRENT_TIMESTAMP
	WHERE walletID = @Wallet_id
END;
---------------------------------------- 2.4o -------------------------------------
GO
CREATE PROCEDURE Redeem_voucher_points
@MobileNo char(11),
@voucher_id int
AS 
BEGIN
	DECLARE @VoucherPoints INT;
    DECLARE @AccountPoints INT;
	SELECT @VoucherPoints = points
        FROM Voucher
        WHERE voucherID = @voucher_id;
	SELECT @AccountPoints = point
        FROM Customer_Account
        WHERE mobileNo = @MobileNo;
	IF ((SELECT v.expiry_date FROM Voucher v WHERE v.voucherID = @voucher_id) > CURRENT_TIMESTAMP) and (@VoucherPoints<@AccountPoints)
		BEGIN
			UPDATE Voucher 
			SET mobileNo = @MobileNo , redeem_date = CURRENT_TIMESTAMP
			WHERE voucherID = @voucher_id;
			UPDATE Customer_Account
			SET point = point - @VoucherPoints
			WHERE mobileNo = @MobileNo;
		END
	ELSE
		BEGIN
			PRINT 'Cannot redeem voucher'
		END
END;
