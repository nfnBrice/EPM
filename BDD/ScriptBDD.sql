#weird : data type float not accepted so use of decimal but not optimum.

DROP DATABASE IF EXISTS ma_base ;
CREATE DATABASE IF NOT EXISTS ma_base;
USE ma_base;


# DATABASE SETUP

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
    Status VARCHAR(30),
    Coupon decimal,
    Issue_amount int,
    USD_equivalent int,
    Nominal int,
    Outstanding_value int,
    ISIN VARCHAR(20),
    Start_of_placement DATE,
    End_of_placement DATE,
    Maturity DATE,
    Foreign_rating VARCHAR(30),
    Local_rating VARCHAR(30),
    Stock_exchange VARCHAR(50),
    Trade_date DATE,
    Indicative_price decimal,
    Effective_yield decimal,
    Duration decimal,
    Vector_image VARCHAR(10000),
    #Profit INT,
    #Period VARCHAR(30),
    #Parvalue VARCHAR(30),
    PortfolioID int,
    FOREIGN KEY (PortfolioID) REFERENCES Portfolio(PortfolioID)
    );

CREATE TABLE Stock(
    StockID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Code VARCHAR(50),
    Name VARCHAR(100)
    );

CREATE TABLE Project(
    ProjectID INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    );

CREATE TABLE PortfolioLink(
    PortfolioLinkID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    PortfolioID INT,
    StockID INT,
    FOREIGN KEY (PortfolioID) REFERENCES Portfolio(PortfolioID),
    FOREIGN KEY (StockID) REFERENCES Stock(StockID)
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

# STORED PROCEDURES SETUP

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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_StockNamebyID`(
    IN p_StockID INT
    )
    BEGIN
        select * from Stock where StockID = StockID;
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
    BEGIN
        select * from PortfolioLink;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_linkStockToPortfolio`(
    IN p_portfolioID INT,
    IN p_stockToAddID INT
    )
    BEGIN
        insert into PortfolioLink
        (
            PortfolioID,
            StockID
        )
        values
        (
            p_portfolioID,
            p_stockToAddID
        );
        SELECT * from PortfolioLink where PortfolioLinkID = LAST_INSERT_ID();
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateWeights`(
    IN p_portfolioID INT,
    IN p_stockID INT,
    IN p_weight float
    )
    BEGIN
        UPDATE PortfolioLink SET Weight=p_weight WHERE PortfolioID = p_portfolioID AND StockID = p_stockID;
    END$$
    DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getLinkDataFromPortfolioID`(
    IN p_portfolioID INT
    )
    BEGIN
        select * from PortfolioLink where PortfolioID = p_portfolioID;
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
        DELETE from PortfolioLink where PortfolioID = p_portfolioID;
        DELETE from Portfolio where PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;

# TO ADD TO DATABASE
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getPortfolioFromPortfolioID`(
    IN p_portfolioID INT
    )
    BEGIN
        select * from Portfolio where PortfolioID = p_portfolioID;
    END$$
    DELIMITER ;
