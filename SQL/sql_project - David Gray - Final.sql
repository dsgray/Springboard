/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name, membercost
FROM  `Facilities`
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(membercost)
FROM  `Facilities`
WHERE membercost >0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities`
WHERE membercost < ( .2 * monthlymaintenance )


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT facid, guestcost, initialoutlay, membercost, monthlymaintenance, name
FROM  `Facilities`
WHERE facid =1
UNION ALL
SELECT facid, guestcost, initialoutlay, membercost, monthlymaintenance, name
FROM  `Facilities`
WHERE facid =5

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, (
CASE
WHEN monthlymaintenance >100
THEN  "expensive"
WHEN monthlymaintenance <=100
THEN  "cheap"
END
) AS costcheck
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname, MAX( joindate )
FROM Members
HAVING MAX( joindate )

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT members.firstname, members.surname,
CASE WHEN bookings.facid =0 THEN  'Tennis Court 1'
ELSE  'Tennis Court 2'
END AS tennis_court
FROM Members members
LEFT JOIN Bookings bookings ON members.memid = bookings.memid
WHERE bookings.facid =0
OR bookings.facid =1
ORDER BY members.firstname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* I worked on this solution and solved parts of it by searching online */

select CONCAT(Members.firstname,  ' ', Members.surname ) as name,
	Facilities.name as facility,
	case
		when Members.memid = 0 then
			Bookings.slots*Facilities.guestcost
		else
			Bookings.slots*Facilities.membercost
	end as cost
        from
                Members
                inner join Bookings
                        on Members.memid = Bookings.memid
                inner join Facilities
                        on Bookings.facid = Facilities.facid
        where
		Bookings.starttime LIKE  '2012-09-14%' and (
			(Members.memid = 0 and Bookings.slots*Facilities.guestcost > 30) or
			(Members.memid != 0 and Bookings.slots*Facilities.membercost > 30)
		)
order by cost desc;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
/* Based on solution found online*/


SELECT *
FROM (
    SELECT CONCAT( Members.firstname,  ' ', Members.surname ) AS fullname, Facilities.name,
    CASE WHEN Members.memid =0 THEN Bookings.slots * Facilities.guestcost
    ELSE Bookings.slots * Facilities.membercost
    END AS cost
FROM  `Bookings`
    INNER JOIN  `Members` ON Bookings.memid = Members.memid
    INNER JOIN  `Facilities` ON Bookings.facid = Facilities.facid
     ) AS daycosts
WHERE cost >30
ORDER BY cost DESC;


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* Based on a solution found online */

SELECT Facilities.name, SUM(Bookings.slots * (
CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost ELSE Facilities.membercost END)) AS revenue
FROM Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
GROUP BY Facilities.name
HAVING SUM(Bookings.slots * (CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost ELSE Facilities.membercost END)) < 1000
ORDER BY revenue;
