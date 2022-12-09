# shebang line
# enable debugging

from dbconfig import *
import pymysql
import cgi
import cgitb
cgitb.enable()

#	Establish a cursor for MySQL connection.
db = get_mysql_param()
cnx = pymysql.connect(user=db['user'], 
                      password=db['password'],
                      host=db['host'],
                      # port needed only if it is not the default number, 3306.
                      # port = int(db['port']), 
                      database=db['database'])

#created cursor objects to parse through SQL queries. Two queries are needed for my sid != None solutions hence the two cursor objects                          
cursor = cnx.cursor()
cursor2 = cnx.cursor()

#	Create HTTP response header
print("Content-Type: text/html;charset=utf-8")
print()

#	Create a primitive HTML starter
print ('''<html>
<head></head>
<body>
''')

#	Get HTTP parameter, swimmer id
form = cgi.FieldStorage()
sid = form.getfirst('sid')

if sid is None:
    #	No HTTP parameter sid: show all swimmers, their caretakers, and the number of events they participated in
    print('<h3>All swimmers</h3>')

    query = '''
WITH t1 AS
(
    SELECT DISTINCT swimmer.SwimmerId, CONCAT(swimmer.FName, ' ', swimmer.LName) AS swimmer, CONCAT(caretaker.FName, " ", 	  caretaker.LName) AS pc, COUNT(othercaretaker.CT_Id) AS numoc
	FROM swimmer INNER JOIN caretaker ON (swimmer.Main_CT_Id = caretaker.CT_Id)
			 LEFT JOIN othercaretaker ON (swimmer.SwimmerId = othercaretaker.SwimmerId)
	GROUP BY swimmer.SwimmerId
),
t2 AS
(
    SELECT DISTINCT swimmer.SwimmerId, CONCAT(swimmer.FName, ' ', swimmer.LName) AS "swimmer", COUNT(participation.EventId) AS nume
	FROM swimmer INNER JOIN participation ON (swimmer.SwimmerId = participation.SwimmerId)
	GROUP BY swimmer.SwimmerId
)
SELECT DISTINCT t1.SwimmerId, CONCAT("<a href='?sid=", t1.swimmerId, "'>'", t1.swimmer) AS swimmera, t1.pc AS 'primary caretaker', t1.numoc AS 'number of other caretakers', t2.nume AS 'number of events'
FROM t1 INNER JOIN t2 ON (t1.SwimmerId = t2.swimmerId);
'''
# "<a href='?sid=", t1.swimmerid, "'>'", t1.swimmer -> hyper link of t1.swimmer (ex: Bobby Khan) where link is : .../hw7.py?sid=<swimmerId>
# <tr> = table row begin, </tr> = table row end, <td> = table cell data begin, </td> = table cell data end

#making html table to hold query results
    print('''
    <table border='1'>
    <tr><th>swimmer id</th><th>swimmer</th></th><th>primary caretaker</th><th>number of other caretakers</th><th>number of events</th></tr>
    ''')

    cursor.execute(query)
    for (swimmerid, swimmer, pc, numoc, nume) in cursor:
        print("<tr><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td></tr>".format(swimmerid, swimmer, pc, numoc, nume))
    print('</body></html>')
    cursor.close()
    cursor2.close()
    cnx.close()		
    quit()
	
if sid is not None:	#	This will always be satisfied at this point.
    #	Show swimmer information.
    #   The query is the same as HW #7.
    query1 = '''
SELECT DISTINCT swimmer.SwimmerId, meet.MeetId, meet.Title
FROM swimmer INNER JOIN participation ON (swimmer.SwimmerId = participation.SwimmerId)
			INNER JOIN event ON (participation.EventId = event.EventId)
            INNER JOIN meet ON (event.MeetId = meet.MeetId)    
WHERE swimmer.SwimmerId = %s;
'''
#Two SQL queries used as this assignment was my first introduction to html coding and I could not think of / implement a solution that only used 1 query
    query2 = '''
SELECT DISTINCT swimmer.SwimmerId, meet.MeetId, event.Title, participation.Result, participation.Comment
FROM swimmer INNER JOIN participation ON (swimmer.SwimmerId = participation.SwimmerId)
 			INNER JOIN event ON (participation.EventId = event.EventId)
           INNER JOIN meet ON (event.MeetId = meet.MeetId)    
WHERE swimmer.SwimmerId = %s AND meet.MeetId= %s;
'''

    #   Show the meets and events a swimmer participated in.
    print("<h3>Meets and events participated by swimmer id #" + str(sid) + "</h3>") #Creates a page heading ie. a title

    cursor.execute(query1,(int(sid),)) #first cursor object and first query responsible for creating the list of meets a swimmer has participated in
    print("<ol>") #begin ordered list

    for (swimmerId,meetid,meetTitle) in cursor: #loop through cursor 1 and extract the necessary info for the creation of the ordered list of meets
        print("Meet #", meetid, " (", meetTitle, "):")

        print("<ol>") #begin second ordered list
        cursor2.execute(query2, (int(sid), meetid)) # second cursor object and second query responsible for creating the numbered list of events, results, and comments the swimmer has

        for(swimid, meetId, eventTitle, result, comment) in cursor2: #loop through cursor 2 and extract the necessary info for the creation of the numbered list of events
            if(result == None):
                resultActual = "no result"
            else:                           #if results are null then print 'no result' else print the result
                resultActual = result

            if(comment == None):
                commentActual = "no comment"
            else:                           #if comments are null then print 'no comment' else print the comment
                commentActual = comment
            
            print("    <li><a href>", eventTitle , "</a>: " , resultActual , " and" , commentActual, "</li>") #begin numerical listing of events the swimmer participated in for the given meet
            
        print('</ol>') #end second ordered list
    print ("</ol>") #end first ordered list

                  
cursor.close()
cursor2.close()
cnx.close()		
				  
print ('''</body>
</html>''')