import os
import json
from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required

# Configure application
app = Flask(__name__)

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///wellness.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


# Start Page
@app.route("/", methods=["GET", "POST"])
@login_required
def welcome():
    # Update user's total points:
    points = db.execute("""SELECT SUM(points) AS totalpoints FROM goals
    WHERE user_id = :user_id AND complete = :completed""", user_id=session["user_id"], completed="Yes")
    totalpoints = points[0]["totalpoints"]
    db.execute(""" UPDATE users SET totalpoints = ?""", totalpoints)
    return render_template("welcome.html")

# Pet Page
@app.route("/pet", methods=["GET", "POST"])
@login_required
def pet():
    # Choose user pet
    if request.method == "POST":
        pet = request.form.get("pet")
        if not pet:
            return apology("Missing info", 400)
        db.execute("UPDATE users SET pet = ? WHERE id = ?", pet, session["user_id"])
        return redirect("/setgoals")

    else:
        return render_template("pet.html")

# Set Goals
@app.route("/setgoals", methods=["GET", "POST"])
@login_required
def setgoals():
    if request.method == "POST":

        # Variables
        goal = request.form.get("goal")
        priority = request.form.get("priority")
        duedate = request.form.get("duedate")
        # Error checks
        if not goal:
            return apology("Missing Goal")
        if not priority:
            return apology("Missing Priority")

        # Insert goal in database
        db.execute("""INSERT INTO goals
        (user_id, goal, priority, date_due)
        VALUES (:user_id, :goal, :priority, :duedate)
        """, user_id=session["user_id"], goal=goal, priority=priority, duedate=duedate)

        # Update goal's date
        db.execute(""" UPDATE goals SET date_made = DATE()
        WHERE user_id = :user AND goal = :goal AND priority = :priority
        """, user=session["user_id"], goal=goal, priority=priority)

        # UPDATE goals with 5 different priorities corresponding point system
        priorities = db.execute("""SELECT priority
        FROM goals WHERE user_id = ?""", session["user_id"])

        # Update points to match priority level
        for row in priorities:
            prioritylevel = row["priority"]
            if prioritylevel == "Very High":
                db.execute(""" UPDATE goals SET points = 5
                WHERE user_id = :user AND goal = :goal AND priority = :priority""", user=session["user_id"], goal=goal, priority=priority)
            elif prioritylevel == "High":
                db.execute(""" UPDATE goals SET points = 4
                WHERE user_id = :user AND goal = :goal AND priority = :priority""", user=session["user_id"], goal=goal, priority=priority)
            elif prioritylevel == "Medium":
                db.execute(""" UPDATE goals SET points = 3
                WHERE user_id = :user AND goal = :goal AND priority = :priority""", user=session["user_id"], goal=goal, priority=priority)
            elif prioritylevel == "Low":
                db.execute(""" UPDATE goals SET points = 2
                WHERE user_id = :user AND goal = :goal AND priority = :priority""", user=session["user_id"], goal=goal, priority=priority)
            elif prioritylevel == "Very Low":
                db.execute(""" UPDATE goals SET points = 1
                WHERE user_id = :user AND goal = :goal AND priority = :priority""", user=session["user_id"], goal=goal, priority=priority)
        return render_template("/goalset.html")
    else:
        return render_template("setgoals.html")

# See today's goals
@app.route("/goals", methods=["GET", "POST"])
@login_required
def goals():
    # Fetch all today's goals
    if request.method == "POST":
        # Allow users to check off their goals using the checkbox forms on templates
        completedgoals = request.form.getlist("complete")
        if not completedgoals:
            return apology("Check off goals!", 400)
        for goal in completedgoals:
            db.execute(""" UPDATE goals SET complete = "Yes", date_completed = DATE()
            WHERE user_id = :user AND goal = :goal""", user=session["user_id"], goal=goal)
        return render_template("completed.html")
    # Display user's goals
    else:
        goals = db.execute("""SELECT points, goal, priority, complete, date_made, date_due,
        CASE WHEN date_made=DATE() THEN 'Today'
        WHEN date_made<DATE() THEN 'Lesser' ELSE 'Greater' END AS "time" FROM goals
        WHERE user_id = ? AND complete = ?""", session["user_id"], "No")

        # Update user's total points:
        points = db.execute("""SELECT SUM(points) AS totalpoints FROM goals
        WHERE user_id = :user_id AND complete = :completed""", user_id=session["user_id"], completed="Yes")
        totalpoints = points[0]["totalpoints"]
        db.execute(""" UPDATE users SET totalpoints = ?""", totalpoints)

        # Return all goals
        return render_template("goals.html", goals=goals)

@app.route("/progress", methods=["GET", "POST"])
@login_required
def progress():
    # Display total goal progress
    totalgoals = db.execute(
        """SELECT goal,points,priority,date_made,complete,date_completed FROM goals WHERE user_id = ?""", session["user_id"])
    # Calculate total points:
    points = db.execute("""SELECT SUM(points) AS totalpoints FROM goals
    WHERE user_id = :user_id AND complete = :completed""", user_id=session["user_id"], completed="Yes")
    totalpoints = points[0]["totalpoints"]

    # Create Chart:
    dailypoints = db.execute("""SELECT SUM(points) AS "daily_points", date_completed
    FROM goals WHERE user_id = ? AND date_completed IS NOT NULL GROUP BY date_completed""", session["user_id"])

    # Calculate total points earned by day
    dailytotalpoints = []
    dates = []
    for row in dailypoints:
        dailytotalpoints.append(row["daily_points"])
        dates.append(row["date_completed"])
    print(dates)
    print(dailytotalpoints)
    # Return all to template
    return render_template("progress.html", goals=totalgoals, totalpoints=totalpoints, xdata=json.dumps(dates), ydata=json.dumps(dailytotalpoints))

# Display user's pet
@app.route("/trackpet", methods=["GET"])
@login_required
def trackpet():
    points = db.execute("""SELECT SUM(points) AS totalpoints FROM goals
    WHERE user_id = :user_id AND complete = :completed""", user_id=session["user_id"], completed="Yes")
    totalpoints = points[0]["totalpoints"]
    if not totalpoints:
        totalpoints = 0
    pet = db.execute("SElECT pet FROM users WHERE id = ?", session["user_id"])
    userpet = pet[0]["pet"]
    if not userpet:
        return redirect("/pet")
    if userpet == "Bulbasaur":
        return render_template("bpet.html", totalpoints=totalpoints)
    if userpet == "Eevee":
        return render_template("epet.html", totalpoints=totalpoints)
    if userpet == "Pikachu":
        return render_template("ppet.html", totalpoints=totalpoints)
    if userpet == "Squirtle":
        return render_template("spet.html", totalpoints=totalpoints)
    if userpet == "Charmander":
        return render_template("cpet.html", totalpoints=totalpoints)

@app.route("/articles", methods=["GET", "POST"])
@login_required
def articles():
    return render_template("articles.html")

# Register

@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "POST":
        # Check for possible errors:

        # No username
        if not request.form.get("username"):
            return apology("Invalid/Blank Username", 400)
        # No password
        elif not request.form.get("password"):
            return apology("Invalid/Blank Password", 400)
        # No confirmation
        elif not request.form.get("confirmation"):
            return apology("Invalid/Blank Confirmation", 400)
        # Passwords don't match
        elif not request.form.get("password") == request.form.get("confirmation"):
            return apology("Passwords Do Not Match", 400)

        # Check if username already in database
        usernames = db.execute(
            "SELECT username FROM users WHERE username = ? ", request.form.get("username"))
        if usernames:
            return apology("Username already taken", 400)

        # Generate hash of password:
        encryptedpassword = generate_password_hash(
            request.form.get("password"))

        # Insert user info in database:
        db.execute("INSERT INTO users (username,hash) VALUES (?,?)",
                   request.form.get("username"), encryptedpassword)

        # Use cookie to log user in:
        userID = db.execute(
            "SELECT id FROM users WHERE username = ?", request.form.get("username"))
        session["user_id"] = userID[0]["id"]

        return redirect("/")
        # User clicks register Display Registration Page
    else:
        return render_template("register.html")

# Log in
@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute("SELECT * FROM users WHERE username = ?",
                          request.form.get("username"))

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(rows[0]["hash"], request.form.get("password")):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")

# Log out

@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/login")

