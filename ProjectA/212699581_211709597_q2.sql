
CREATE TABLE Company (
    Symbol          VARCHAR(10)  PRIMARY KEY,
    Sector          VARCHAR(40),
    Founded         INTEGER,
    Location        VARCHAR(40),
);


CREATE TABLE Investor (
    iId             VARCHAR(9) PRIMARY KEY,
    BirthDate       DATE,
        CHECK (Year(BirthDate)<2004),
    Email           VARCHAR(100) UNIQUE ,
        check (Email like '_%@%_'),
    RegDate         DATE
);


CREATE TABLE Rivalry (
    company1        VARCHAR(10),
    company2        VARCHAR(10),
        CHECK (company1 != company2),
    reason          VARCHAR(100) NOT NULL,
    Primary Key (company1, company2),
    FOREIGN KEY (company1) REFERENCES Company(Symbol),
    FOREIGN KEY (company2) REFERENCES Company(Symbol)
);


CREATE TABLE Stock (
    Symbol          VARCHAR(10),
    tDate           DATE,
    Price           FLOAT,
    PRIMARY KEY (Symbol, tDate),
    FOREIGN KEY (Symbol) REFERENCES Company(Symbol) ON DELETE CASCADE
);


CREATE TABLE Buy (
    iId             VARCHAR(9),
    Symbol          VARCHAR(10),
    Date            DATE,
    FOREIGN KEY (iId) REFERENCES Investor(iId),
    FOREIGN KEY (Symbol) REFERENCES Company(Symbol)

);


CREATE TABLE [Transaction] (
  date          DATE,
  iId           VARCHAR(9),
  Amount        FLOAT,
    check (Amount >= 1000),
  PRIMARY KEY (date, iId),
  FOREIGN KEY (iId)
      REFERENCES Investor(iId) ON DELETE CASCADE
);


CREATE TABLE PremiumInvestor (
    iId VARCHAR(9) PRIMARY KEY,
    Goal VARCHAR,
    FOREIGN KEY (iId)
        REFERENCES Investor(iId) ON DELETE CASCADE
);


CREATE TABLE BeginnerInvestor (
    iId         VARCHAR(9) PRIMARY KEY,
    FOREIGN KEY (iId) REFERENCES Investor(iId) ON DELETE CASCADE,
);


CREATE TABLE Lawyer (
    lid VARCHAR(9),
    Decision VARCHAR,
    FOREIGN KEY (lid)
        REFERENCES Investor(iId)
);

CREATE TABLE Economist (
    eId VARCHAR(9),
    Blog VARCHAR(100),
    FOREIGN KEY (eId)
        REFERENCES Investor(iId)
);

CREATE TABLE GuidedBy (
    iId VARCHAR(9),
    eId VARCHAR(9),
    FOREIGN KEY (iId)
        REFERENCES Investor(iId),
    FOREIGN KEY (eId) REFERENCES Economist(eId)
);

CREATE TABLE Examine(
    Decision VARCHAR (100),
    iId varchar(9),
    Date DATE,
    lid VARCHAR (9),
    PRIMARY KEY (iId, lid,Date),
    FOREIGN KEY (lid)
        REFERENCES Lawyer(lid),
    FOREIGN KEY (iId,Date)
        REFERENCES Transaction(iId,date),
);


 CREATE TABLE Interested (
     CSymbol1       VARCHAR(10),
     CSymbol2       VARCHAR(10),
     eId            VARCHAR(9),
     Blog           VARCHAR(100),
     PRIMARY KEY (CSymbol1, CSymbol2),
     FOREIGN KEY (CSymbol1) REFERENCES Company(Symbol),
     FOREIGN KEY (CSymbol2) REFERENCES Company(Symbol),
     FOREIGN KEY (eId) REFERENCES Economist(eId),

 );



