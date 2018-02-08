#IMPORT FLASK
from flask import Flask, render_template, json, request
from flask.ext.mysql import MySQL
from werkzeug import generate_password_hash, check_password_hash
from flask import session
from flask import redirect
import string
import requests
import optimiz as optimiz
import pandas as pd
app = Flask(__name__)
app.secret_key = 'why would I tell you my secret key?'

#data base configuration 
mysql = MySQL()
# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'root'
app.config['MYSQL_DATABASE_DB'] = 'ma_base'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
app.config['MYSQL_DATABASE_PORT'] = 8889
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://dayenu:secret.word@localhost/dayenu?unix_socket=/usr/local/mysql5/mysqld.sock'

mysql.init_app(app)

#WEBPAGES INITIALISATION 
#home webpage init
@app.route('/')
def main():
	return render_template('index.html')

#################################################### USER ####################################################
@app.route('/userHome')
def UserHome():
	if session.get('user'):
		try: 
			#create mysql connection
			conn = mysql.connect()
			#create cursor
			cursor = conn.cursor()
			cursor.callproc('sp_getPortfoliosPerUser',(session['user'],))
			data = cursor.fetchall()
			return render_template('userHome.html',data=data)
		finally:
			cursor.close() 
			conn.close()
	else:
		return render_template('error.html',error = 'Unauthorized Access')

@app.route('/showSignUp')
def showSignUp():
	return render_template('signup.html')

@app.route('/showSignIn')
def showSignin():
	return render_template('signin.html')

@app.route('/logout')
def logout():
	session.pop('user',None)
	return redirect('/', code=302)

#signup procedure
@app.route('/signUp', methods=['POST','GET'])
def signUp():
	#create mysql connection
	conn = mysql.connect()
	#create cursor
	cursor = conn.cursor()
	try: 
		# read the posted values from the UI
		_name = request.form['inputName']
		_email = request.form['inputEmail']
		_password = request.form['inputPassword']
		# validate the received values
		if _name and _email and _password:
			#password generation
			_hashed_password = generate_password_hash(_password)
			#call the procedure create user 
			cursor.callproc('sp_createUser',(_email,_name,_hashed_password))
			#test to know if the data was well created 
			data = cursor.fetchall()
			if len(data) is 0:
				conn.commit()
				return json.dumps({'message':'User created successfully !'})
			else:
				return json.dumps({'error':str(data[0])})
		else:
			return json.dumps({'html':'<span>Enter the required fields</span>'})
	except Exception as e:
		return json.dumps({'error':str(e)})
	finally:
		cursor.close() 
		conn.close()

#SignIn procedure
@app.route('/validateLogin',methods=['POST'])
def signIn():
	#try:
	_email = request.form['inputEmail']
	_password = request.form['inputPassword']
	conn = mysql.connect()
	cursor = conn.cursor()
	cursor.callproc('sp_connect', (_email,)) #for some weird reason email is not one element but the number of char it is composed of 
	data = cursor.fetchall()

	if len(data) > 0:
		session['user'] = data[0][0]
		session['portfolio'] =0
		if check_password_hash(str(data[0][3]),_password):
			session['user'] = data[0][0]
			return redirect('/userHome')
		else:
			return render_template('error.html',error = 'Wrong Email address or Password.')
	else:
		#return render_template('error.html',error = 'caca')
		return render_template('index.html')

	#except Exception as e:
	#	return render_template('error.html',error = str(e))	

	#finally:
		#cursor.close() 
		#conn.close()

#################################################### PORTFOLIO ####################################################

@app.route("/showCreatePortfolio")
def showCreatePortfolio():
    return render_template('createPortfolio.html')

@app.route('/showPortfolio',methods=['POST','GET'])
def showPortfolio():
	#try:
	print(session['portfolio'])
	conn = mysql.connect()
	cursor = conn.cursor()
	stocks = [ ]
	bonds = [ ]

	cursor.callproc('sp_getStockLinkDataFromPortfolioID',(session['portfolio'],))
	dataStock = cursor.fetchall()

	for each in dataStock:
		CurrentStock = [ ]
		cursor.callproc('sp_getStockInfoFromLinkID',(each[4],))
		CurrentStocks = cursor.fetchall()
		CurrentStock.append(each[2])
		CurrentStock.append(CurrentStocks[0][2])
		CurrentStock.append(CurrentStocks[0][1])
		CurrentStock.append(each[1])
		stocks.append(CurrentStock)

	cursor.callproc('sp_getBondLinkDataFromPortfolioID',(session['portfolio'],))
	dataBond = cursor.fetchall()

	for each in dataBond:
		CurrentBond = [ ]
		cursor.callproc('sp_getBondInfoFromLinkID',(each[4],))
		CurrentBonds = cursor.fetchall()
		CurrentBond.append(each[2])
		CurrentBond.append(CurrentBonds[0][10])
		CurrentBond.append(CurrentBonds[0][1])
		CurrentBond.append(each[1])
		bonds.append(CurrentBond)

	cursor.callproc('sp_getPortfolioFromPortfolioID',(session['portfolio'],))
	portfolio = cursor.fetchall()
	return render_template('portfolio.html', portfolioName=portfolio[0][4], portfolioAmount=portfolio[0][1], portfolioRisk=portfolio[0][5], stocks=stocks, bonds=bonds)
	#finally:
	session['portfolio']=0
	cursor.close() 
	conn.close()

@app.route('/createPortfolio', methods=['POST','GET'])
def addPortfolio():
	#create mysql connection
	conn = mysql.connect()
	#create cursor
	cursor = conn.cursor()
	try: 
		# read the posted values from the UI
		_name = request.form['inputName']
		_amount = request.form['inputAmount']
		_horizon = request.form['inputHorizon']
		_risk = request.form['inputRisk']
		_knowledge = request.form['inputKnowledge']

		# validate the received values
		if _amount and _horizon and _knowledge:
			if _knowledge is 0:
				return render_template('tutorial.html')
			else :
				#find portfolio 
				cursor.callproc('sp_createPortfolio', (_amount, _horizon, session['user'],_name,_risk))
				data = cursor.fetchall()
				if len(data) is 0:
					return json.dumps({'error':str(data[0])})
				else:
					conn.commit()
					session['portfolio'] = data[0][0] 
					return redirect('/showAdd')
		else:
			return json.dumps({'html':'<span>Enter the required fields</span>'})
	#except Exception as e:
	#	return json.dumps({'error':str(e)})
	finally:
		cursor.close() 
		conn.close()

@app.route('/deletePortfolio', methods=['POST','GET'])
def deletePortfolio():
		try: 
			#create mysql connection
			conn = mysql.connect()
			cursor = conn.cursor()
			_portfolioToDelete = request.form['inputPortfolioToDelete']
			#create cursor
			_int_portfolioToDelete= int(_portfolioToDelete)
			print(_int_portfolioToDelete)
			cursor.callproc('sp_deletePortfolio',(_int_portfolioToDelete,)) 
			conn.commit()
			return redirect('/userHome')
		finally:
			cursor.close() 
			conn.close()

@app.route('/showUpdatePortfolio', methods=['POST','GET'])
def showUpdatePortfolio():
	#try:
	conn = mysql.connect()
	cursor = conn.cursor()
	stocks = [ ]
	bonds = [ ]

	cursor.callproc('sp_getStockLinkDataFromPortfolioID',(session['portfolio'],))
	dataStock = cursor.fetchall()

	for each in dataStock:
		CurrentStock = [ ]
		cursor.callproc('sp_getStockInfoFromLinkID',(each[4],))
		CurrentStocks = cursor.fetchall()
		CurrentStock.append(each[2])
		CurrentStock.append(CurrentStocks[0][2])
		CurrentStock.append(CurrentStocks[0][1])
		stocks.append(CurrentStock)

	cursor.callproc('sp_getBondLinkDataFromPortfolioID',(session['portfolio'],))
	dataBond = cursor.fetchall()

	for each in dataBond:
		CurrentBond = [ ]
		print(each)
		cursor.callproc('sp_getBondInfoFromLinkID',(each[4],))
		CurrentBonds = cursor.fetchall()
		CurrentBond.append(each[1])#name
		CurrentBond.append(CurrentBonds[0][2])
		CurrentBond.append(CurrentBonds[0][1])
		bonds.append(CurrentBond)

	cursor.callproc('sp_getPortfolioFromPortfolioID',(session['portfolio'],))
	portfolio = cursor.fetchall()
	return render_template('updatePortfolio.html', portfolioName=portfolio[0][4], portfolioAmount=portfolio[0][1], portfolioRisk=portfolio[0][5], stocks=stocks,bonds=bonds)
	#finally:
	cursor.close() 
	conn.close()

@app.route('/changePortfolioNbForUpdate', methods=['POST'])
def changePortfolioNbForUpdate():
	session['portfolio']= int(request.form['inputPortfolioToUpdate'])
	return redirect('/showUpdatePortfolio')

@app.route('/changePortfolioNbForShow', methods=['POST'])
def changePortfolioNbForShow():
	session['portfolio']= int(request.form['inputPortfolioToShow'])
	return redirect('/showPortfolio')

@app.route ('/updateName', methods=['POST','GET'])
def updateName():
	try:
		conn = mysql.connect()
		cursor = conn.cursor()
		_NewName = request.form['newName']
		print(_NewName)
		cursor.callproc('sp_updateNamePortfolio',(_NewName, session['portfolio']))
		conn.commit()
		return redirect('/showUpdatePortfolio')
	finally: 
		cursor.close() 
		conn.close()

@app.route ('/updateRisk', methods=['POST'])
def updateRisk():
	try:
		conn = mysql.connect()
		cursor = conn.cursor()
		_NewRisk = int(request.form['newRisk'])
		cursor.callproc('sp_updateRiskPortfolio',(_NewRisk, session['portfolio']))
		conn.commit()
		return redirect('/showUpdatePortfolio')
	finally:
		cursor.close() 
		conn.close()

@app.route ('/updateAmount', methods=['POST'])
def updateAmount():
	try:
		conn = mysql.connect()
		cursor = conn.cursor()
		_NewAmount = request.form['newAmount']
		cursor.callproc('sp_updateAmountPortfolio',(_NewAmount, session['portfolio']))
		conn.commit()
		return redirect('/showUpdatePortfolio')
	finally:
		cursor.close() 
		conn.close()

@app.route('/showAdd')
def showAdd():
	try:
		#create mysql connection
		conn = mysql.connect()
		#create cursor
		cursor = conn.cursor()
		cursor.callproc('sp_getAllStocks', ())
		stocks = cursor.fetchall()

		cursor.callproc('sp_getAllBonds', ())
		bonds = cursor.fetchall()
		return render_template('add.html', stocks=stocks, bonds=bonds)
	finally:
		cursor.close() 
		conn.close()

#################################################### STOCKS ####################################################

@app.route('/showAddStocks')
def showStocks():
	try:
		#create mysql connection
		conn = mysql.connect()
		#create cursor
		cursor = conn.cursor()
		cursor.callproc('sp_getAllStocks', ())
		data = cursor.fetchall()
		return render_template('addStocks.html', data=data)
	except Exception as e:
		return render_template('error.html',error = str(e))	
	finally:
		cursor.close() 
		conn.close()

@app.route('/addStocks',methods=['POST'])
def addStocks():
	conn = mysql.connect()
	#create cursor
	cursor = conn.cursor()
	print("portfolio")
	print(session['portfolio'])
	try:
		cursor.callproc('sp_getStockLinkDataFromPortfolioID', (session['portfolio'],))
		isThereLinksInPortfolio = cursor.fetchall()
		f = request.form
		print(isThereLinksInPortfolio)

		#if isThereLinksInPortfolio means the portfolio is full -> ask user to modify it or create a new one. 
		if(isThereLinksInPortfolio):
			cursor.callproc('sp_emptyStocksPortfolio', (session['portfolio'],))
		caca=[ ]
		for key in f.keys():
			session['key']=int(key);
			cursor.callproc('sp_linkStockToPortfolio', (session['portfolio'], session['key']))
			portfolioLinkToStockAdded = cursor.fetchall()
			caca.append(portfolioLinkToStockAdded[0][4])
			conn.commit()
		optimiz.optimiz(caca)
		return redirect('/showPortfolio')
	finally:
		cursor.close() 
		conn.close()

@app.route ('/showUpdateStocks', methods=['POST'])
def showUpdateStocks():
	try:
		#create mysql connection
		conn = mysql.connect()
		#create cursor
		cursor = conn.cursor()
		cursor.callproc('sp_getAllStocks', ())
		data = cursor.fetchall()
		return render_template('updateStocks.html', data=data)
	except Exception as e:
		return render_template('error.html',error = str(e))	
	finally:
		cursor.close() 
		conn.close()

#################################################### BONDS ####################################################

@app.route('/showAddBonds')
def showBonds():
	try:
		#create mysql connection
		conn = mysql.connect()
		#create cursor
		cursor = conn.cursor()
		cursor.callproc('sp_getAllBonds', ())
		data = cursor.fetchall()
		return render_template('addBonds.html', data=data)
	except Exception as e:
		return render_template('error.html',error = str(e))		
	finally:
		cursor.close() 
		conn.close()

@app.route('/addBonds',methods=['POST'])
def addBonds():
	conn = mysql.connect()
	#create cursor
	cursor = conn.cursor()
	try:
		cursor.callproc('sp_getBondLinkDataFromPortfolioID', (session['portfolio'],))
		isThereLinksInPortfolio = cursor.fetchall()
		print(isThereLinksInPortfolio)
		f = request.form

		#if isThereLinksInPortfolio means the portfolio is full -> ask user to modify it or create a new one. 
		if(isThereLinksInPortfolio):
			cursor.callproc('sp_emptyBondsPortfolio', (session['portfolio'],))
		caca=[ ]
		for key in f.keys():
			session['key']=int(key);
			cursor.callproc('sp_linkBondsToPortfolio', (session['portfolio'], session['key']))
			portfolioLinkToBondAdded = cursor.fetchall()
			caca.append(portfolioLinkToBondAdded[0][4])
			conn.commit()
		#optimiz.optimiz(caca)
		return redirect('/showPortfolio')
	finally:
		cursor.close() 
		conn.close()

@app.route ('/showUpdateBonds', methods=['POST'])
def showUpdateBonds():
	try:
		#create mysql connection
		conn = mysql.connect()
		#create cursor
		cursor = conn.cursor()
		cursor.callproc('sp_getAllBonds', ())
		data = cursor.fetchall()
		return render_template('updateBonds.html', data=data)
	except Exception as e:
		return render_template('error.html',error = str(e))	
	finally:
		cursor.close() 
		conn.close()


#debug mode -> put to false when dev mode is finished
if __name__ == '__main__':
	app.run(debug=True, port=5002)