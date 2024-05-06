# CS50 Final Project : Wellness Watcher
## By: Sarah Moreno, Taspia Khan, and Thang Ho
<br>

A website via which users can create an account, pick a wellness watcher, make and track goals where they receive points upon completion, watch their wellness watcher evolve as they accumulate points, and read wellness articles to get informed on the importance of mental health.
<br>
<br>

## Background

More than 60% of college students meet the criteria for at least one mental health problem. Furthermore, the surgeon general warned of a youth mental health crisis where there has been a rise in adolescent depression, anxiety, and mental health distress due to the coronavirus pandemic. There are many resources and websites that encourage productivity however, we must first prioritize wellness and self-love to achieve happiness and success. Therefore, the goal of the Wellness Watcher website is to look after the mental health and wellbeing of its users.

## Running

Start Flask's built-in web server (within `wellnesswatcher/`):

```
$ flask run
```

Visit the URL outputted by `flask` to see the distribution code in action. You won't be able to log in or register, though, just yet!
<br>
<br>

## Understanding
<br>

#### `app.py`


<br>

#### `helpers.py/`
Next take a look at `helpers.py`. Ah, there's the implementation of `apology`. Notice how it ultimately renders a template, `apology.html`. It also happens to define within itself another function, `escape`, that it simply uses to replace special characters in apologies. By defining `escape` inside of `apology`, we've scoped the former to the latter alone; no other functions will be able (or need) to call it.

Next in the file is `login_required` which makes sure other app.routes are only called when the user is logged in.

<br>

#### `static/`

Glance too at `static/`, inside of which is `styles.css` which is where some initial CSS lives, as well as the many graphics used throughout our Wellness Watcher website.


#### `templates/`

First, `register/` permits the user to create an account on Wellness Watcher through allowing them to input their username and password. In `login.html` is, essentially, just an HTML form, stylized with [Bootstrap](http://getbootstrap.com/). Meanwhile, `apology.html`, is a template for an apology. Recall that `apology` in `helpers.py` took two arguments: `message`, which was passed to `render_template` as the value of `bottom`, and, optionally, `code`, which was passed to `render_template` as the value of `top`. Notice in `apology.html` how those values are ultimately used! And [here's why](https://github.com/jacebrowning/memegen) 0:-)

Next is `layout.html`. It's a bit bigger than usual, but that's mostly because it comes with a fancy, mobile-friendly "navbar" (navigation bar), also based on Bootstrap. Notice how it defines a block, `main`, inside of which templates (including `apology.html` and `login.html`) shall go. It also includes support for Flask's [message flashing](https://flask.palletsprojects.com/en/1.1.x/quickstart/#message-flashing) so that the website can relay messages from one route to another for the user to see. The purpose for layout is creating a general template which will be extended onto other templates.

Like `layout.html`, if you take a look at `articles.html`, you will also notice that it uses a lot of bootstrap to display wellness articles for mental health education. Understanding the importance of mental health is crucial in having people improve. Therefore, Wellness Watcher has a page dedicated to educational resources.

The first page the user visits is `welcome.html` which welcomes the user through showing the prevalence of mental health issues in college students and prompts them to choose their pet through a button.

Now, `pet.html` allows for the user to choose their preferred wellness pet through a form. Then, if you take a look, `bpet.html`, `cpet.html`, `epet.html`, `ppet.html`, and `spet.html` all serve the same function in displaying the different evolutions of each respective wellness watcher, depending on which pet the user chose. This is done through corresponding the amount of points that the user has to the different evolutions of the same pet the user chose.

Next, `setgoals.html` uses a form to prompt the user to input a goal manually or select from suggestions in a dropdown menu, select its priority, and due date. `goalset.html` is then responsible for notifying that the user has successfully set a goal. Then, `goals.html` displays a table with all of this information for current goals.

Once a user successfully completes a goal, `completed.html` comes into play by notifying the user that their goal was successfully completed and displays how mamy points the user has gained.A

Finally, if you take a look at `progress.html` you will notice that this template displays a table with all of the users past and present goals and all of its respective information. In addition to this, this page outputs a chart with the points that the user has accumulated each day. This will give the user a visual to represent how many wellness tasks completed to keep the users accountable!
<br>
<br>

## Specification

### `/`
```
Beginning Line 33, users are redirected to our welcome homepage while in the backend, our server updates the users' totalpoints.
```

### `pet`
```
Beginning Line 44, this route allows users to choose their wellness watcher pet
```
### `setgoals`
```
Beginning Line 59, this route allows users to set their goals.

In the backend, it uses 3 request.form.get to store the inputted goal, priority, and due date while returning error messages for missing goals or priorities

Afterwards, we will insert this goal into our `goals` SQL table via db.execute and automatically update this goal's date using the built-in DATE() function in SQL.

Next we will assign points to each goal depending on what level priority the user sets (Very High = 5, Very Low = 1)

```
### `goals`
```
Beginning Line 112, this route displays all of the users' current and incomplete goals of the day while also allowing the user to check off their goals via the checkbox feature on the goals table.
```
### `progress`
```
Beginning Line 141, this app route allows users to see their entire history of goals, complete and incomplete, a Javascript data chart that tallies up total daily points by day, and their total wellness points altogether.
```
### `trackpet`
```
Beginning Line 168, this app route uses the user's totalpoints to display their chosen pet and respective evolutions. If they have not chosen a pet yet, they will be redirected to the /pet or "Choose Your Watcher" page to determine their pet.
```

### `articles`
```
Beginning Line 191, this route simply brings the users to a page of external articles on wellness and mental health
```
### `register`
```
Beginning Line 198, this route registers users.
```
### `login`
```
Beginning Line 242, this route logs users in.
```
### `logout`
```
Beginning Line 280, this route logs users out and clears the cookie session_id.
```

## Video
### Here is our live demonstration video: https://youtu.be/lW6sk8p_dUI
