-- Bare Bone DDL to create and populate the SWIM DB of CSCI 4333

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS SWIM;
CREATE SCHEMA SWIM;
USE SWIM;

-- You may use the following DELETE TABLE
-- to ensure starting with a clean slate.
-- Note the DELETE TABLE is usually in the
-- reverse order of CREATE TABLE to ensure
-- no referential integrity violations.
DROP TABLE IF EXISTS Commitment;
DROP TABLE IF EXISTS V_Task;
DROP TABLE IF EXISTS V_TaskList;
DROP TABLE IF EXISTS Participation;
DROP TABLE IF EXISTS `Event`;
DROP TABLE IF EXISTS Meet;
DROP TABLE IF EXISTS LevelHistory;
DROP TABLE IF EXISTS OtherCaretaker;
DROP TABLE IF EXISTS Swimmer;
DROP TABLE IF EXISTS Venue;
DROP TABLE IF EXISTS Level;
DROP TABLE IF EXISTS Caretaker;
DROP TABLE IF EXISTS Coach;

-- Create tables
DROP TABLE IF EXISTS Coach;
CREATE TABLE Coach(
    CoachId      INT UNSIGNED AUTO_INCREMENT, 
    LName        VARCHAR(30) NOT NULL,
    FName        VARCHAR(30) NOT NULL,
    Phone        VARCHAR(12) NOT NULL,
    EMail        VARCHAR(60) NOT NULL,
    CONSTRAINT Coach_pk PRIMARY KEY(CoachId)
);

DROP TABLE IF EXISTS Caretaker;
CREATE TABLE Caretaker(
    CT_Id        INT UNSIGNED AUTO_INCREMENT, 
    LName        VARCHAR(30) NOT NULL,
    FName        VARCHAR(30) NOT NULL,
    Phone        VARCHAR(12) NOT NULL,
    EMail        VARCHAR(60) NOT NULL,
    CONSTRAINT Caretaker_pk PRIMARY KEY(CT_Id)
);

DROP TABLE IF EXISTS Level;
CREATE TABLE Level(
    LevelId      INT UNSIGNED, 
    -- ok to use smaller INT such as TINYINT
    Level        VARCHAR(30) NOT NULL,
    Description  VARCHAR(250),
    CONSTRAINT level_pk PRIMARY KEY(LevelId),
    CONSTRAINT level_ck_1 UNIQUE(Level)
);

DROP TABLE IF EXISTS Venue;
CREATE TABLE Venue(
    VenueId     INT UNSIGNED AUTO_INCREMENT, 
    -- ok to use smaller INT such as SMALLINT
    Name        VARCHAR(100) NOT NULL,
    Address     VARCHAR(100) NOT NULL,
    City        VARCHAR(50) NOT NULL,
    State       VARCHAR(15) NOT NULL,
    ZipCode     VARCHAR(10) NOT NULL,
    Phone       VARCHAR(12) NOT NULL,
    CONSTRAINT venue_pk PRIMARY KEY(VenueId),
    CONSTRAINT venue_ck_1 UNIQUE(Name)
);

DROP TABLE IF EXISTS Swimmer;
CREATE TABLE Swimmer(
    SwimmerId       INT UNSIGNED AUTO_INCREMENT, 
    LName           VARCHAR(30) NOT NULL,
    FName           VARCHAR(30) NOT NULL,
    Phone           VARCHAR(12) NOT NULL,
    EMail           VARCHAR(60) NOT NULL,
    JoinTime        DATE NOT NULL,
    CurrentLevelId  INT UNSIGNED NOT NULL,
    Main_CT_Id      INT UNSIGNED NOT NULL,
    Main_CT_Relationship VARCHAR(30) NOT NULL,
    Main_CT_Since   DATE NOT NULL,
    CONSTRAINT swimmer_pk PRIMARY KEY(SwimmerId),
    CONSTRAINT swimmer_level_fk FOREIGN KEY(CurrentLevelId) 
        REFERENCES Level(LevelId),
    CONSTRAINT swimmer_caretaker_fk FOREIGN KEY(Main_CT_Id) 
        REFERENCES Caretaker(CT_Id)
);

DROP TABLE IF EXISTS OtherCaretaker;
CREATE TABLE OtherCaretaker(
    OC_Id        INT UNSIGNED AUTO_INCREMENT, 
    SwimmerId    INT UNSIGNED NOT NULL,
    CT_Id        INT UNSIGNED NOT NULL,
    Relationship VARCHAR(30) NOT NULL,
    Since        DATE NOT NULL,
    CONSTRAINT othercaretaker_pk PRIMARY KEY(OC_Id),
    CONSTRAINT othercaretaker_swimmer_fk FOREIGN KEY(SwimmerId) 
        REFERENCES Swimmer(SwimmerId),
    CONSTRAINT othercaretaker_caretaker_fk FOREIGN KEY(CT_Id) 
        REFERENCES Caretaker(CT_Id)
);

DROP TABLE IF EXISTS LevelHistory;
CREATE TABLE LevelHistory(
    LH_Id        INT UNSIGNED AUTO_INCREMENT, 
    SwimmerId    INT UNSIGNED NOT NULL,
    LevelId      INT UNSIGNED NOT NULL,
    StartDate    DATE NOT NULL,
    Comment      VARCHAR(250),
    CONSTRAINT levelhistory_pk PRIMARY KEY(LH_Id),
    CONSTRAINT levelhistory_ck_1 UNIQUE(SwimmerId, LevelId),
    CONSTRAINT levelhistory_swimmer_fk FOREIGN KEY(SwimmerId) 
        REFERENCES Swimmer(SwimmerId),
    CONSTRAINT levelhistory_level_fk FOREIGN KEY(LevelId) 
        REFERENCES Level(LevelId)
);

DROP TABLE IF EXISTS Meet;
CREATE TABLE Meet(
    MeetId      INT UNSIGNED AUTO_INCREMENT, 
    Title       VARCHAR(100) NOT NULL,
    Date        DATE NOT NULL,
    StartTime   TIME NOT NULL,
    EndTime     TIME NOT NULL,
    VenueId     INT UNSIGNED NOT NULL,
    CoachId     INT UNSIGNED NOT NULL,
    CONSTRAINT meet_pk PRIMARY KEY(MeetId),
    CONSTRAINT meet_venue_fk FOREIGN KEY(VenueId) 
        REFERENCES Venue(VenueId),
    CONSTRAINT meet_coach_fk FOREIGN KEY(CoachId) 
        REFERENCES Coach(CoachId)
);

DROP TABLE IF EXISTS `Event`;
CREATE TABLE `Event`(
    EventId      INT UNSIGNED AUTO_INCREMENT, 
    Title        VARCHAR(100) NOT NULL,
    StartTime    TIME NOT NULL,
    EndTime      TIME NOT NULL,
    MeetId       INT UNSIGNED NOT NULL,
    LevelId      INT UNSIGNED NOT NULL,
    CONSTRAINT event_pk PRIMARY KEY(EventId),
    CONSTRAINT event_meet_fk FOREIGN KEY(MeetId) 
        REFERENCES Meet(MeetId),
    CONSTRAINT event_level_fk FOREIGN KEY(LevelId) 
        REFERENCES Level(LevelId)
);

DROP TABLE IF EXISTS Participation;
CREATE TABLE Participation(
    ParticipationId INT UNSIGNED AUTO_INCREMENT, 
    SwimmerId       INT UNSIGNED NOT NULL,
    EventId         INT UNSIGNED NOT NULL,
    Committed       BOOLEAN,
    CommitTime      DATETIME,
    Participated    BOOLEAN,
    Result          VARCHAR(100),
    Comment         VARCHAR(100),
    CommentCoachId  INT UNSIGNED,
    CONSTRAINT participation_pk PRIMARY KEY(ParticipationId),
    CONSTRAINT participation_ck_1 UNIQUE(SwimmerId, EventId),
    CONSTRAINT participation_swimmer_fk FOREIGN KEY(SwimmerId) 
        REFERENCES Swimmer(SwimmerId),
    CONSTRAINT participation_event_fk FOREIGN KEY(EventId) 
        REFERENCES `Event`(EventId),
    CONSTRAINT participation_coach_fk FOREIGN KEY(CommentCoachId) 
        REFERENCES Coach(CoachId)
);

DROP TABLE IF EXISTS V_TaskList;
CREATE TABLE V_TaskList(
    VTL_Id      INT UNSIGNED AUTO_INCREMENT, 
    MeetId      INT UNSIGNED NOT NULL,
    Required    BOOLEAN NOT NULL,
    Description VARCHAR(250) NOT NULL,
    Penalty     VARCHAR(100),
    PenaltyAmt  DECIMAL(6,2),
    CONSTRAINT v_tasklist_pk PRIMARY KEY(VTL_Id),
    CONSTRAINT v_tasklist_meet_fk FOREIGN KEY(MeetId) 
        REFERENCES Meet(MeetId)
);

DROP TABLE IF EXISTS V_Task;
CREATE TABLE V_Task(
    VT_Id       INT UNSIGNED AUTO_INCREMENT, 
    VTL_Id      INT UNSIGNED NOT NULL,
    Name        VARCHAR(100) NOT NULL,
    Comment     VARCHAR(250),
    Num_V       SMALLINT UNSIGNED DEFAULT 1,
    CONSTRAINT v_task_pk PRIMARY KEY(VT_Id),
    CONSTRAINT v_task_v_tasklist_fk FOREIGN KEY(VTL_Id) 
        REFERENCES V_TaskList(VTL_Id)
);

DROP TABLE IF EXISTS Commitment;
CREATE TABLE Commitment(
    CommitmentId    INT UNSIGNED AUTO_INCREMENT, 
    CT_Id           INT UNSIGNED NOT NULL,
    VT_Id           INT UNSIGNED NOT NULL,
    CommitTime      DATETIME NOT NULL,
    Rescinded       BOOLEAN,
    RescindTime     DATETIME,
    CarriedOut      BOOLEAN,
    Comment         VARCHAR(100),
    CommentCoachId  INT UNSIGNED,
    CONSTRAINT commitment_pk PRIMARY KEY(CommitmentId),
    CONSTRAINT commitment_ck_1 UNIQUE(CT_Id, VT_Id),
    CONSTRAINT commitment_caretaker_fk FOREIGN KEY(CT_Id) 
        REFERENCES Caretaker(CT_Id),
    CONSTRAINT commitment_v_task_fk FOREIGN KEY(VT_Id)
        REFERENCES V_Task(VT_Id),
    CONSTRAINT commitment_coach_fk FOREIGN KEY(CommentCoachId) 
        REFERENCES Coach(CoachId)
);

-- Populate the Swim DB of CSCI 4333

INSERT INTO Coach(CoachId, FName, LName, Phone, EMail) VALUES
    (1,'Joe', 'Smith', '713-222-9413', 'joesmile_1061@gmail.com'),
    (2,'Jane', 'Smith', '713-222-9414', 'janesmile_1061@gmail.com'),
    (3,'Paul', 'Lam', '713-486-2011', 'paulkkk@hotmail.com'),
    (4,'Paulina', 'Hall', '832-486-1997', 'paulinathenice@yahoo.com'),
    (5,'Katrina', 'Bajaj', '832-117-2435', 'KatrinaBajaj@gmail.com');
     
INSERT INTO Caretaker(CT_Id, FName, LName, Phone, EMail) VALUES
    (1,'Azalea', 'Khan', '832-116-2992', 'theAKhan@gmail.com'),
    (2,'Joseph', 'Khan', '832-116-2993', 'theJKhan@gmail.com'),
    (3,'Jim', 'Khan', '832-116-2994', 'theJKhan2@gmail.com'),
    (4,'Katie', 'Johnson', '713-014-0090', 'KatieJohnson1010@yahoo.com'),
    (5,'Elizabeth', 'Johnson', '713-014-2090', 'EJohnson5111@yahoo.com'),
    (6,'Benjamin', 'Smith', '281-290-1929', 'BSmith_honeywell@gmail.com');

INSERT INTO Level (LevelId, Level, Description) VALUES
    (1, 'Green', 'First Level'),
    (2, 'Blue', 'Second level'),
    (3, 'Yellow', 'Third level'),
    (4, 'Pink', 'Fourth level'),
    (5, 'Orange', 'Fifth level'),
    (6, 'Lime', 'Six level'),
    (7, 'Purple', 'Seventh level'),
    (8, 'Red', 'Eigth level'),
    (9, 'Brown', 'Ninth level'),
    (10, 'Black', 'Tenth level');

INSERT INTO Venue(VenueId, Name, Address, City, State, ZipCode, Phone) VALUES
    (1,'UHCL', '2700 Bay Area Boulevard', 'Houston','Texas', 
        '77058', '281-283-3700'),
    (2,'CLHS', '3300 Bay Area Boulevard', 'Houston', 'Texas',
        '77059', '713-126-4544'),
    (3,'BAHEP', '1260 Gemini Way Boulevard', 'Webster', 'Texas',
        '77047', '713-789-2999');
       
INSERT INTO Swimmer(SwimmerId, FName, LName, Phone, EMail, JoinTime, 
    CurrentLevelId, Main_CT_Id, Main_CT_Relationship, Main_CT_Since) VALUES
    (1,'Bobby', 'Khan', '832-116-2992', 'theBKhan1@gmail.com',
        '2014-2-12', 3, 1, 'Mother', '2014-2-12'),
    (2,'Billy', 'Khan', '832-116-2992', 'theBKhan2@gmail.com',
        '2015-12-12', 2, 1, 'Mother', '2015-12-12'),
    (3,'Nina', 'Khan', '832-116-2992', 'theNinaKhan@gmail.com',
        '2016-5-12', 2, 2, 'Father', '2017-5-12'),
    (4,'Clara', 'Johnson', '713-222-1010', 'ClaraJohnson_11@yahoo.com',
        '2013-5-12', 3, 4, 'Mother', '2015-5-12'),
    (5,'Philip', 'Johnson', '713-222-1010', 'PhilipJohnson_108@yahoo.com',
        '2015-5-15', 2, 5, 'Mother', '2015-5-15'),
    (6, 'Joe', 'Fen', '271-909-2733', 'JoeFenTheGreat@gmail.com',
        '2018-3-13', 5, 4, 'Aunt', '2019-1-1');
   
INSERT INTO OtherCaretaker(SwimmerId, CT_Id, Relationship, Since) VALUES
    (1,2,'Uncle','2014-2-12'),
    (1,3,'Uncle','2014-2-12'),
    (2,3,'Uncle','2016-1-3'),
    (3,1,'Aunt','2016-5-12'),
    (3,3,'Adult Friend','2016-5-12'),
    (4,5,'Aunt','2016-1-12');  

INSERT INTO LevelHistory(SwimmerId, LevelId, StartDate) VALUES
    (1,2,'2014-7-15'),
    (2,1,'2015-12-12'),
    (2,2,'2016-4-15'),
    (3,1,'2016-5-12'),
    (4,2,'2014-6-1'),
    (4,3,'2015-10-2'),
    (5,1,'2015-5-15'),
    (5,2,'2016-3-15'),
    (6,5,'2018-2-14');
    
INSERT INTO LevelHistory(SwimmerId, LevelId, StartDate, Comment) VALUES
    (1,1,'2014-2-12','Good spirit'),
    (1,3,'2016-1-19','Fast time'),
    (3,2,'2016-7-12', 'Fast advance'),
    (4,1,'2013-5-12','Freestyle best'),
    (6,4,'2018-1-1','Club record in Freestyle50');
     
INSERT INTO Meet(MeetId, Title, Date, StartTime, EndTime, VenueId, CoachId) VALUES
    (1,'UHCL Open', '2016-3-3', '09:00:00', '16:00:00', 1, 1),
    (2,'Shell Trial', '2016-8-4', '08:00:00', '11:00:00', 2, 1),
    (3,'Clear Lake Contest', '2019-7-4', '10:00:00', '15:00:00', 2, 2);
 
INSERT INTO Event(EventId,Title, StartTime, EndTime, MeetId, LevelId) VALUES
    (1,'50M Butterfly', '09:10:00', '09:30:00', 1, 2),
    (2,'100M Freestyle', '09:40:00', '09:50:00', 1, 2),
    (3,'100M Butterfly', '10:10:00', '10:30:00', 1, 3),
    (4,'200M Freestyle', '10:40:00', '10:50:00', 1, 3),
    (5,'50M Butterfly', '09:15:00', '09:35:00', 2, 2),
    (6,'100M Freestyle', '09:45:00', '09:55:00', 2, 2),
    (7,'100M Butterfly', '10:15:00', '10:35:00', 2, 3),
    (8,'200M Freestyle', '10:45:00', '10:55:00', 2, 3),
    (9,'100M Breaststroke', '11:15:00', '10:35:00', 2, 3),
    (10,'200M Backstroke', '10:15:00', '10:55:00', 3, 5),
    (11,'50M Breaststroke', '11:15:00', '10:35:00', 3, 3);

INSERT INTO Participation(SwimmerId, EventId) VALUES(2,1);
INSERT INTO Participation(SwimmerId, EventId, Committed)
    VALUES(3,1,1);
INSERT INTO Participation(SwimmerId, EventId, Committed, CommitTime, 
        Participated, Result, Comment, CommentCoachId)
    VALUES(5,1,1,'2016-2-20 10:00:00', 1, 'Winner', 'Good!', 2);
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(3,2);
INSERT INTO Participation(SwimmerId, EventId, Committed)
    VALUES(2,2,1);
INSERT INTO Participation(SwimmerId, EventId, Committed, CommitTime, 
        Participated, Result, Comment, CommentCoachId)
    VALUES(5,2,1,'2016-2-20 10:00:00', 1, 'Winner', 'Second winner', 2);
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(1,3);
INSERT INTO Participation(SwimmerId, EventId, Committed)
    VALUES(4,3,1);
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(1,4);
INSERT INTO Participation(SwimmerId, EventId, Committed, CommitTime, 
        Participated, Result)
    VALUES(4,5,1,'2016-1-15 12:00:00', 1, 'Runner up');
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(2,5);
INSERT INTO Participation(SwimmerId, EventId, Committed)
    VALUES(3,5,1);
INSERT INTO Participation(SwimmerId, EventId, Committed, CommitTime, 
        Participated, Result, Comment, CommentCoachId)
    VALUES(5,5,1,'2016-3-20 10:00:00', 1, '1:12:20', 'Good!', 1);
INSERT INTO Participation(SwimmerId, EventId, Committed, CommitTime, 
        Participated, Result, Comment, CommentCoachId)
    VALUES(2,6,1,'2016-3-9 10:00:00', 1, 'Good', 'Need to focus', 3);
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(3,6);
INSERT INTO Participation(SwimmerId, EventId, Committed)
    VALUES(5,6,1);
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(1,7);
INSERT INTO Participation(SwimmerId, EventId, Committed)
    VALUES(4,7,1);
INSERT INTO Participation(SwimmerId, EventId, Committed, CommitTime, 
        Participated, Result)
    VALUES(1,8,1,'2016-1-21 12:00:00', 1, 'winner');
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(4,8);
INSERT INTO Participation(SwimmerId, EventId)
    VALUES(1,9),(3,9),(6,10),(1,11);

INSERT INTO V_TaskList(VTL_Id, MeetId, Required, Description)    
    VALUES(1,1,0,'UHCL meet volunteer tasks');
INSERT INTO V_TaskList(VTL_Id, MeetId, Required, Description, Penalty, PenaltyAmt)    
    VALUES(2,2,1,'Shell Trial meet volunteer tasks','3 credits', 0);
INSERT INTO V_TaskList(VTL_Id, MeetId, Required, Description)    
    VALUES(3,3,0,'Clear Lake Contest task lists');
    
INSERT INTO V_Task(VT_Id, VTL_Id, Name, Comment, Num_V) 
    VALUES(1,1,'Officiating','Must be trained',2);
INSERT INTO V_Task(VT_Id, VTL_Id, Name, Num_V)
    VALUES(2,1,'Recording',3);
INSERT INTO V_Task(VT_Id, VTL_Id, Name)
    VALUES(3,1,'Diecting traffic');
INSERT INTO V_Task(VT_Id, VTL_Id, Name, Comment, Num_V)
    VALUES(4,2,'Officiating','Must be trained',3);
INSERT INTO V_Task(VT_Id, VTL_Id, Name, Num_V)
    VALUES(5,2,'Recording',2);
INSERT INTO V_Task(VT_Id, VTL_Id, Name)
    VALUES(6,2,'Diecting traffic');
    
INSERT INTO Commitment(CT_Id, VT_Id, CommitTime) VALUES
    (1,1,'2015-10-10 11:11:12'),
    (4,1,'2015-10-11 12:11:20'),
    (2,2,'2016-1-10 11:05:12'),
    (3,2,'2016-1-11 12:12:20'),
    (5,2,'2016-1-17 09:19:25'),
    (1,3,'2015-10-10 11:11:12');
    
INSERT INTO Commitment(CT_Id, VT_Id, CommitTime,CarriedOut,
        Comment, CommentCoachId) VALUES
    (1,4,'2016-05-11 11:47:22',1,'Very dependable',1),
    (4,4,'2016-05-12 06:37:12',0,'Sick and called',1),
    (5,4,'2016-05-12 06:37:12',1,'Brought fruit',2);
INSERT INTO Commitment(CT_Id, VT_Id, CommitTime,Rescinded) VALUES
    (2,5,'2016-03-11 11:33:12',1),
    (4,5,'2016-03-17 12:35:14',0);
INSERT INTO Commitment(CT_Id, VT_Id, CommitTime) VALUES
    (1,5,'2016-05-11 11:47:22'),
    (5,6,'2016-06-11 09:15:22');
    
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;