#weird : data type float not accepted so use of decimal but not optimum.

DROP DATABASE IF EXISTS ma_base ;
CREATE DATABASE IF NOT EXISTS ma_base;
USE ma_base;


<<<<<<< HEAD
###################################### DATABASE SETUP ######################################
=======
# DATABASE SETUP
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8

CREATE TABLE Users(
    UserID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Mail VARCHAR(100),
    Pseudo VARCHAR(100),
    Mdp VARCHAR(250),
    AversionRisque VARCHAR(30)
    );

CREATE TABLE Portfolio(
    PortfolioID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Amount decimal DEFAULT 0,
    Horizon DATE DEFAULT 0,
    UserID INT,
    Name VARCHAR(50),
    Risk float,
    FOREIGN KEY (UserID) REFERENCES Users (UserID)
    );

CREATE TABLE Bond(
    BondID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    Issue VARCHAR (250),
    Country VARCHAR(50),
    Issuer VARCHAR (100),
    Currency VARCHAR(3),
    Coupon decimal,
    Issue_amount int,
    USD_equivalent int,
    Nominal int,
    Outstanding_value int,
    ISIN VARCHAR(20),
    Start_of_placement DATE,
    End_of_placement DATE,
    Foreign_rating VARCHAR(30),
    Local_rating VARCHAR(30),
    Stock_exchange VARCHAR(50),
    Trade_date DATE,
    Indicative_price decimal,
    Effective_yield decimal,
    Duration decimal,
    #Profit INT,
    #Period VARCHAR(30),
    #Parvalue VARCHAR(30),
    );

CREATE TABLE Stock(
    StockID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Code VARCHAR(50),
    Name VARCHAR(100)
    );

CREATE TABLE Project(
    ProjectID INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    );

<<<<<<< HEAD
CREATE TABLE PortfolioLinkToStock(
    PortfolioLinkToStockID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Quantity INT DEFAULT 0,
    Weight INT DEFAULT 0,
=======
CREATE TABLE PortfolioLink(
    PortfolioLinkID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    PortfolioID INT,
    StockID INT,
    FOREIGN KEY (PortfolioID) REFERENCES Portfolio(PortfolioID),
    FOREIGN KEY (StockID) REFERENCES Stock(StockID)
    );

CREATE TABLE PortfolioLinkToBond(
    PortfolioLinkToBondID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Quantity INT DEFAULT 0,
    Weight INT DEFAULT 0,
    PortfolioID INT,
    BondID INT,
    FOREIGN KEY (PortfolioID) REFERENCES Portfolio(PortfolioID),
    FOREIGN KEY (BondID) REFERENCES Bond(BondID)
    );

CREATE TABLE Pricehistory(
    PriceHistoryID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ClosingPrice float,
    HighestPrice float,
    LowestPrice float,
    OpeningPrice float,
    PriceTime DATE,
    StockID INT,
    FOREIGN KEY (StockID) REFERENCES Stock(StockID)
    );

###################################### STORED PROCEDURE SETUP ##############################


########################################## USERS ###########################################
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createUser`(
    IN p_mail VARCHAR(100),
    IN p_pseudo VARCHAR(100),
    IN p_mdp VARCHAR(250)
    )
    BEGIN
        if ( select exists (select 1 from Users where Pseudo = p_pseudo) ) THEN

            select 'Username Exists !!';

        ELSE
            if ( select exists (select 1 from Users where Mail = p_mail) ) THEN
            select 'You already have an account !!';

            ELSE

                insert into Users
                (
                    Mail,
                    Pseudo,
                    Mdp
                )
                values
                (
                    p_mail,
                    p_pseudo,
                    p_mdp
                );
            END IF;
        END IF;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_connect`
    (
        IN p_mail VARCHAR(100)
    )

    BEGIN
        select * from Users where Mail = p_mail;
    END$$
    DELIMITER ;


######################################### PORTFOLIO ########################################
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createPortfolio`(
    IN p_amount decimal,
    IN p_horizon DATE,
    IN p_userIDs INT(250),
    IN p_name VARCHAR(50),
    IN p_risk INT(100)
    )
    BEGIN
        insert into Portfolio
        (
            Amount,
            Horizon,
            UserID,
            Name,
            Risk
        )
        values
        (
            p_amount,
            p_horizon,
            p_userIDs,
            p_name,
            p_risk
        );
        SELECT LAST_INSERT_ID();
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getPortfoliosPerUser`(
    IN p_userID INT
    )
    BEGIN   
        select * from Portfolio where UserID = p_userID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deletePortfolio`(
    IN p_portfolioID INT
    )
    BEGIN   
        DELETE from PortfolioLinkToStock where PortfolioID = p_portfolioID;
        DELETE from Portfolio where PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateNamePortfolio`(
    IN p_name VARCHAR(50),
    IN p_portfolioID int 
    )
    BEGIN   
        UPDATE Portfolio SET Name=p_name WHERE PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateRiskPortfolio`(
    IN p_risk INT(100),
    IN p_portfolioID INT 
    )
    BEGIN   
        UPDATE Portfolio SET Risk=p_risk WHERE PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getPortfolioFromPortfolioID`(
    IN p_portfolioID INT
    )
    BEGIN   
        select * from Portfolio where PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateAmountPortfolio`(
    IN p_amount INT,
    IN p_portfolioID INT
    )
    BEGIN   
        UPDATE Portfolio SET Amount=p_amount WHERE PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;


######################################### STOCKS ###########################################
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_StockNamebyID`(
    IN p_StockID INT
    )
<<<<<<< HEAD
    BEGIN     
        select * from Stock where StockID = p_StockID;
=======
    BEGIN
        select * from Stock where StockID = StockID;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllStocks`()
    BEGIN
        select * from Stock;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getStocksbyID`()
<<<<<<< HEAD
    BEGIN     
        select * from PortfolioLinkToStock;
=======
    BEGIN
        select * from PortfolioLink;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_linkStockToPortfolio`(
<<<<<<< HEAD
    IN p_portfolioID INT, 
    IN p_stockToAddID INT
    )
    BEGIN     
        insert into PortfolioLinkToStock
=======
    IN p_portfolioID INT,
    IN p_stockToAddID INT
    )
    BEGIN
        insert into PortfolioLink
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
        (
            PortfolioID,
            StockID
        )
        values
        (
            p_portfolioID,
            p_stockToAddID
        );
        SELECT * from PortfolioLinkToStock where PortfolioLinkToStockID = LAST_INSERT_ID();
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getOCHLbyStockID`(
    IN p_stockID INT
    )

    BEGIN
         select * from Pricehistory where StockID = p_stockID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateStockWeights`(
    IN p_portfolioID INT,
    IN p_stockID INT,
    IN p_weight float
    )
<<<<<<< HEAD
    BEGIN   
        UPDATE PortfolioLinkToStock SET Weight=p_weight WHERE PortfolioID = p_portfolioID AND StockID = p_stockID;
=======
    BEGIN
        UPDATE PortfolioLink SET Weight=p_weight WHERE PortfolioID = p_portfolioID AND StockID = p_stockID;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getStockLinkDataFromPortfolioID`(
    IN p_portfolioID INT
    )
<<<<<<< HEAD
    BEGIN   
        select * from PortfolioLinkToStock where PortfolioID = p_portfolioID;
=======
    BEGIN
        select * from PortfolioLink where PortfolioID = p_portfolioID;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getStockInfoFromLinkID`(
    IN p_stockID INT
    )
    BEGIN
        select * from Stock where StockID = p_stockID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_emptyStocksPortfolio`(
    IN p_portfolioID INT
    )
<<<<<<< HEAD
    BEGIN   
        DELETE from PortfolioLinkToStock where PortfolioID = p_portfolioID;
=======
    BEGIN
        select * from Portfolio where UserID = p_userID;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;


######################################### BONDS ############################################
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BondsNamebyID`(
    IN p_BondID INT
    )
    BEGIN     
        select * from Bond where BondID = p_BondID ;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllBonds`()
    BEGIN     
        select * from Bond;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getBondsbyID`()
    BEGIN     
        select * from PortfolioLinkToBond;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_linkBondsToPortfolio`(
    IN p_portfolioID INT, 
    IN p_bondToAddID INT
    )
    BEGIN     
        insert into PortfolioLinkToBond
        (
            PortfolioID,
            BondID
        )
        values
        (
            p_portfolioID,
            p_bondToAddID
        );
        SELECT * from PortfolioLinkToBond where PortfolioLinkToBondID = LAST_INSERT_ID();
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getOCHLbyBondID`(
    IN p_bondID INT
    )
    
    BEGIN     
         select * from Pricehistory where BondID = p_bondID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateBondWeights`(
    IN p_portfolioID INT,
    IN p_bondID INT,
    IN p_weight float
    )
    BEGIN   
        UPDATE PortfolioLinkToBond SET Weight=p_weight WHERE PortfolioID = p_portfolioID AND BondID = p_bondID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getBondLinkDataFromPortfolioID`(
    IN p_portfolioID INT
    )
<<<<<<< HEAD
    BEGIN   
        select * from PortfolioLinkToBond where PortfolioID = p_portfolioID;
=======
    BEGIN
        DELETE from PortfolioLink where PortfolioID = p_portfolioID;
        DELETE from Portfolio where PortfolioID = p_portfolioID;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getBondInfoFromLinkID`(
    IN p_bondID INT
    )
    BEGIN   
        select * from Bond where BondID = p_bondID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_emptyBondsPortfolio`(
    IN p_portfolioID INT
    )
<<<<<<< HEAD
    BEGIN   
        DELETE from PortfolioLinkToBond where PortfolioID = p_portfolioID;
=======
    BEGIN
        select * from Portfolio where PortfolioID = p_portfolioID;
>>>>>>> d132278cd52a0089c041885eeece9df17d57f9b8
    END$$
    DELIMITER ;
