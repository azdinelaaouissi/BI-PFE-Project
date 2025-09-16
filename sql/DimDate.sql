USE snifop_dm;
GO



-- Déclaration des dates
DECLARE @StartDate DATETIME = '19600101';
DECLARE @EndDate DATETIME = '20501231';
DECLARE @CurrentDate DATETIME = @StartDate;
DECLARE @DATE_SK INT = 1;

-- Boucle d'insertion
WHILE @CurrentDate <= @EndDate
BEGIN
    DECLARE @Id_Date INT = CONVERT(INT, CONVERT(VARCHAR(8), @CurrentDate, 112));
    DECLARE @FullDate CHAR(10) = CONVERT(CHAR(10), @CurrentDate, 120);
    DECLARE @DayOfMonth NVARCHAR(2) = CAST(DAY(@CurrentDate) AS NVARCHAR(2));
    DECLARE @DayName NVARCHAR(9) = DATENAME(WEEKDAY, @CurrentDate);
    DECLARE @DayOfWeek CHAR(1) = CAST(DATEPART(WEEKDAY, @CurrentDate) AS CHAR(1));
    DECLARE @DayOfWeekInMonth NVARCHAR(2) = CAST((DAY(@CurrentDate) - 1) / 7 + 1 AS NVARCHAR(2));
    DECLARE @DayOfWeekInYear NVARCHAR(2) = CAST(DATEPART(DAYOFYEAR, @CurrentDate) / 7 + 1 AS NVARCHAR(2));
    DECLARE @DayOfQuarter NVARCHAR(3) = CAST(DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @CurrentDate), 0), @CurrentDate) + 1 AS NVARCHAR(3));
    DECLARE @DayOfYear NVARCHAR(3) = CAST(DATEPART(DAYOFYEAR, @CurrentDate) AS NVARCHAR(3));
    DECLARE @WeekOfMonth NVARCHAR(1) = CAST(DATEDIFF(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, @CurrentDate), 0), @CurrentDate) + 1 AS NVARCHAR(1));
    DECLARE @WeekOfQuarter NVARCHAR(2) = CAST(DATEDIFF(WEEK, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @CurrentDate), 0), @CurrentDate) + 1 AS NVARCHAR(2));
    DECLARE @WeekOfYear NVARCHAR(2) = CAST(DATEPART(WEEK, @CurrentDate) AS NVARCHAR(2));
    DECLARE @Month NVARCHAR(2) = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2);
    DECLARE @MonthName NVARCHAR(9) = DATENAME(MONTH, @CurrentDate);
    DECLARE @MonthOfQuarter NVARCHAR(2) = CAST((MONTH(@CurrentDate) - 1) % 3 + 1 AS NVARCHAR(2));
    DECLARE @Quarter CHAR(1) = CAST(DATEPART(QUARTER, @CurrentDate) AS CHAR(1));
    DECLARE @QuarterName NVARCHAR(9) = CASE DATEPART(QUARTER, @CurrentDate)
                                          WHEN 1 THEN '1er trimestre'
                                          WHEN 2 THEN '2ème trimestre'
                                          WHEN 3 THEN '3ème trimestre'
                                          WHEN 4 THEN '4ème trimestre'
                                       END;
    DECLARE @Year CHAR(4) = CAST(YEAR(@CurrentDate) AS CHAR(4));
    DECLARE @YearName CHAR(7) = 'Année ' + CAST(YEAR(@CurrentDate) AS CHAR(4));
    DECLARE @MonthYear CHAR(10) = @MonthName + ' ' + @Year;
    DECLARE @MMYYYY CHAR(6) = @Month + @Year;

    DECLARE @FirstDayOfMonth DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, @CurrentDate), 0);
    DECLARE @LastDayOfMonth DATE = EOMONTH(@CurrentDate);
    DECLARE @FirstDayOfQuarter DATE = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @CurrentDate), 0);
    DECLARE @LastDayOfQuarter DATE = DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @CurrentDate) + 1, 0));
    DECLARE @FirstDayOfYear DATE = DATEADD(YEAR, DATEDIFF(YEAR, 0, @CurrentDate), 0);
    DECLARE @LastDayOfYear DATE = DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @CurrentDate) + 1, 0));

    DECLARE @Semester CHAR(1) = CASE WHEN MONTH(@CurrentDate) BETWEEN 1 AND 6 THEN '1' ELSE '2' END;
    DECLARE @SemesterName NVARCHAR(10) = CASE WHEN MONTH(@CurrentDate) BETWEEN 1 AND 6 THEN '1er semestre' ELSE '2ème semestre' END;

    DECLARE @SchoolYear NVARCHAR(20);
    IF MONTH(@CurrentDate) >= 9
        SET @SchoolYear = CAST(YEAR(@CurrentDate) AS NVARCHAR(4)) + '/' + CAST(YEAR(@CurrentDate) + 1 AS NVARCHAR(4));
    ELSE
        SET @SchoolYear = CAST(YEAR(@CurrentDate) - 1 AS NVARCHAR(4)) + '/' + CAST(YEAR(@CurrentDate) AS NVARCHAR(4));

    -- Insertion
    INSERT INTO dm.DIM_DATE (
        DATE_SK, Id_Date, Date, Date_Complete, JourDuMois, NomDuJour, JourDeLaSemaine,
        JourDeLaSemaineDansLeMois, JourDeLaSemaineDansLAnnee, JourDuTrimestre, JourDeLAnnee,
        SemaineDuMois, SemaineDuTrimestre, SemaineDeLAnnee, Mois, NomDuMois, MoisDuTrimestre,
        Trimestre, NomDuTrimestre, Annee, NomDeLAnnee, MoisAnnee, MMYYYY, PremierJourDuMois,
        DernierJourDuMois, PremierJourDuTrimestre, DernierJourDuTrimestre, PremierJourDeLAnnee,
        DernierJourDeLAnnee, Semestre, NomDuSemestre, AnneeScolaire
    )
    VALUES (
        @DATE_SK, @Id_Date, @CurrentDate, @FullDate, @DayOfMonth, @DayName, @DayOfWeek,
        @DayOfWeekInMonth, @DayOfWeekInYear, @DayOfQuarter, @DayOfYear, @WeekOfMonth,
        @WeekOfQuarter, @WeekOfYear, @Month, @MonthName, @MonthOfQuarter, @Quarter,
        @QuarterName, @Year, @YearName, @MonthYear, @MMYYYY, @FirstDayOfMonth,
        @LastDayOfMonth, @FirstDayOfQuarter, @LastDayOfQuarter, @FirstDayOfYear,
        @LastDayOfYear, @Semester, @SemesterName, @SchoolYear
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    SET @DATE_SK += 1;
END;

-- Vérification
SELECT COUNT(*) AS NombreDeJours FROM dm.DIM_DATE;
SELECT TOP 400 * FROM dm.DIM_DATE ORDER BY Date;
