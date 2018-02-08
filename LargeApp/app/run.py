from flask import Flask, render_template, redirect
app = Flask(__name__)

@app.route("/")
def main():
    return render_template('index.html')
	
@app.route("/projects")
def project():
    return render_template('projects.html')

if __name__ == "__main__":
    app.run()
	
	