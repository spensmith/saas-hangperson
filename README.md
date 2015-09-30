Creating and versioning a simple SaaS app
==============================
(this implementation guide follows the design of the [hangperson game app](https://github.com/sbunivedu/hangperson))

**Goal:** Understand the steps needed to create, version, and deploy a
SaaS app, including tracking the libraries it depends on so that your
production and development environments are as similar as possible.

Get Starter Code
----------------
Clone this repository to get the starter code.

`git clone https://github.com/sbunivedu/saas-hangperson.git`

The starter code contains a scaffolded Rails app with a controller 
(`app/controllers/games_controller.rb`) and the associated views 
(under `app/views/games`).

You need to copy your `hangperson_game.rb` (solution to part I) to 
the `lib` directory to provide the game logic.

Run Bundler
-----------

Run the command `bundle install --without production`, which examines your `Gemfile` to make
sure the correct gems (and, where specified, the correct versions) are
available, and tries to install them otherwise.  

Introducing Cucumber
====================

Cucumber is a remarkable tool for writing high-level integration and
acceptance tests, terms with which you're already familiar.  We'll learn
much more about Cucumber later, but for now we will use it to *drive*
the development of your app's code.

Just as you used RSpec to "drive" the creation of the class's methods,
you'll next use Cucumber to drive the creation of the SaaS code.

Normally, the cycle would be:

0. Use Cucumber scenario to express end-to-end behavior of a scenario
0. As you start writing the code to make each step of the scenario pass, use RSpec to
drive the creation of that step's code
0. Repeat until all scenario steps are passing green

In this assignment we're skipping the middle step since the goal is to
give you an overview of all parts of the process.  Also, in the first
step, for your own apps you'd be creating the Cucumber scenarios
yourself; in this assignment we've provided them for you.

Cucumber lets you express integration-test scenarios, which you'll find
in the `features` directory in `.feature` files. You'll also see a
`step_definitions` subdirectory with a single file `game_steps.rb`,
containing the code used when each "step" in a scenario is executed as
part of the test.


As an integration testing tool,
Cucumber can be used to test almost any kind of software system as long
as there is a way to *simulate* the system and a way to *inspect* the
system's behavior.  
You select a *back end* for Cucumber based on how the end system is to
be simulated and inspected.

Since a SaaS server is simulated by issuing HTTP
requests, and its behavior can be inspected by looking at the HTML pages
served, we configure Cucumber to use 
[Capybara](https://github.com/jnicklas/capybara), a 
Ruby-based browser simulator that includes a domain-specific language
for simulating browser actions and inspecting the SaaS server's
responses to those actions.

* Self-check: read the section on "Using Capybara with Cucumber" on
Capybara's home page.  Which step definitions use Capybara to simulate
the server as a browser would?  Which step definitions use Capybara to
inspect the app's response to the stimulus?

> Step definitions that use `visit`, `click_button`, `fill_in` are
> simulating a browser by visiting a page and/or filling in a form on
> that page and clicking its buttons.  Those that use `have_content` are
> inspecting the output.

* Self-check: Looking at `features/guess.feature`, what is the
role of the three lines following the "Feature:" heading?

> They are comments showing the purpose and actors of this story.
> Cucumber won't execute them.

* Self-check: In the same file, looking at the scenario step `Given I
start a new game with word "garply"`, what lines in `game_steps.rb` will
be invoked when Cucumber tries to execute this step, and what is the
role of the string `"garply"` in the step?

> Lines 13-16 of the file will execute.  Since a step is chosen by
> matching a regular expression, `word` will match the first (and in
> this case only) parenthesis capture group in the regexp, which in this
> example is `garply`.

## Get your first scenario to pass

We'll first get the "I start a new game" scenario to pass; you'll then
use the same techniques to make the other scenarios pass, thereby
completing the app.  So take a look at the step definition for "I start
a new game with word...".

You already saw that you can load the new game page, but get an error
when clicking the button for actually creating a new game.  You'll now
reproduce this behavior with a Cuke scenario.

* Self-check: When the "browser simulator" in Capybara issues the `visit
'/new'` request, Capybara will do an HTTP GET to the partial URL `/new` on the
app.  Why do you think `visit` always does a GET, rather than giving the
option to do either a GET or a POST in a given step?

> Cucumber/Capybara is only supposed to be able to do what a human user
> can do.  As we discussed earlier, the only way a human user can cause
> a POST to happen via a web browser is submitting an HTML form, which
> is accomplished by `click_button` in Capybara.

Run the "new game" scenario with:

```bash
cucumber features/start_new_game.feature
```
The first step fails because `No route matches [GET] "/" (ActionController::RoutingError)`.
Add a new route to `config/routes.rb`: 

```ruby
root 'games#new'
```
Run the "new game" test again and you will see the first step passes and
get a new error `No route matches [POST] "/create" (ActionController::RoutingError)`. 
This error is expected because the test attempts to click on the link to start 
a new game. Now lets test the app manually to verify the error from the test.

* Run the app in a separate terminal window `rails s -p $PORT -b $IP`
* Visit the homepage and click on "New Game".
* Study the source code till what you see makes sense to you.

The scenario now fails because the `<form>` tag in `views/_new.erb`
points to path `/create` (based on the table of routes we developed in 
part I), which matches no rout. Add the necessary code to the app to 
recognize this route. 

```ruby
post '/create', to: 'games#create'
```

Now the test should complain `The action 'create' could not be found 
for GamesController (AbstractController::ActionNotFound)`.

This "create" method in the app should do the following:

* Call the HangpersonGame class method `get_random_word`

* Create a new instance of HangpersonGame using that word

* Redirect the browser to the `show` action

When you finish this task, you should be able to re-run the scenario and
have all steps passing green. 

You will need to add the following code to games controller
```ruby
def create
  @game = HangpersonGame.new HangpersonGame.get_random_word
  store_game
  redirect_to '/show'
end
```
and the "show" route `get '/show',    to: 'games#show'` 
to `config/routes.rb`.

You will also need to add the "show" method to games controller
```ruby
def show
  load_game
end
```

At that point manually verify this behavior.

* Self-check: What is the significance of using `Given` vs. `When`
vs. `Then` in the feature file?  What happens if you switch them around?
Conduct a simple experiment to find out, then confirm your results by
using the Google.

> The keywords are all aliases for the same method.  Which one you use
> is determined by what makes the scenario most readable.

Develop the scenario for guessing a letter
-------------------------------------------

For this scenario, in `features/guess.feature`, we've already provided a
correct 
`show.erb` HTML file that submits the player's guess to the `guess`
action.  You need to add a `HangpersonGame#guess` method that
has the needed functionality.  

* Self-check: In `game_steps.rb`, look at the code for "I start a new
game..." step, and in particular the `stub_request` command.  Given the
hint that that command is provided by a Gem (library) called `webmock`,
what's going on with that line, and why is it needed?  (Use the Google
if needed.)

> Webmock lets our tests "intercept" HTTP requests coming **from** our
> app and directed to another service.  In this case, it's intercepting
> the POST request (the same one you manually did with `curl` in an
> earlier part of the assignment) and faking the reply value.  This lets
> us enforce deterministic behavior of our tests, and also means we're
> not hitting the real external server each time our test runs.

You need to add the follow route because the test visit the `/new` path.
```ruby
get '/new',     to: 'games#new'
post '/guess',  to: 'games#guess'
```

The special Rails hash `params[]` has a key-value pair for each
nonblank field on a submitted form: the key is the symbolized `name`
attribute of the form field and the value is what the user typed into
that field, or in the case of a checkbox or radiobutton, the
browser-specified values indicating if it's checked or unchecked.
("Symbolized" means the string is converted to a symbol, so `"foo"`
becomes `:foo`.)

* Self-check: In your code for processing a guess, what
expression should you use to extract *just the first character* of
what the user typed in the letter-guess field of the form in `show.erb`?
**CAUTION:** if the user typed nothing, there won't be any matching
key in `params[]`, so dereferencing the form field will give `nil`.  In
that case, your code should return the empty string rather than an
error.

> `params[:guess].to_s[0] || ' '` or its equivalent. `[0]` grabs the first character
> only; for an empty string, it returns an empty string.

In the `guess` code in the Rails app,
you should:

* Extract the letter submitted on the form.  

* Use that letter as a guess on the current game.

* Redirect to the `show` action so the player can see the result of
their guess.

Develop that code and verify that all the steps in
`features/guess.feature` now pass.

```ruby
def guess
  load_game
  letter = params[:guess].to_s || ' '
  @game.guess letter
  store_game
  redirect_to '/show'
end
```
* Debugging tip: The Capybara command `save_and_open_page` placed in a
step definition will cause the step to open a Web browser window showing
what the page looks like at that point in the scenario.  The
functionality is provided in part by a gem called `launchy` which is in
the Gemfile.

Corner Cases
============

By now you should be familiar with the cycle:

0.  Pick a new scenario to work on
0.  Run the scenario and watch it fail
0.  Develop code that makes each step of the scenario pass
0.  Repeat till all steps passing.

Use this process to develop the code for the remaining actions `win` and
`lose`.  You will need to add code to the `show` action that checks
whether the game state it is about to show is actually a winning or
losing state, and if so, it should redirect to the appropriate `win` or
`lose` action.  Recall that your game logic model has a method for
testing if the current game state is win, lose, or keep playing.
The scenario `game_over.feature` tests these behaviors in your SaaS app.

Give yourself a break and play a few rounds of hangperson.

While you're playing, what happens if you directly go to
`http://your_app_url/win`?  Make sure the player cannot cheat by
simply visiting `GET /win`. You can write scenarios in `prevent_cheating.feature`
to test these behaviors.

Deploy to Heroku
----------------
* Register an account at https://www.heroku.com/
* Go to your app directory and run `heroku login` to login to your heroku account.
* Run `heroku create your-app-name` (replace your-app-name with your own app name)
  to create a new app.
* Run `git push heroku master` to deploy your app on heroku.
* Your app will be available at https://your-app-name.herokuapp.com/new

* What to submit:  Make sure all Cucumber scenarios are passing.  A
shorthand way to run all of them is `cucumber features/` which runs all
`.feature` files in the given directory.  When all are passing, deploy
to Heroku and submit the URL of your deployed game.

Conclusion
==========

This assignment has served as a microcosm or miniature tour of the
entire course: during the rest of the course we will investigate each of
these in much more detail, and we will also add new techniques---

* *Test-driven development (TDD)* will let you write much more
detailed tests for your code and determine its **coverage**, that is,
how thoroughly your tests exercise your code.  We will use **RSpec** to
do test-first development, in which we write tests before we write the
code, watch the test fail ("red"), quickly write just enough code to make the
test pass ("green"), clean up (refactor) the code, and go on to the next test.  We
will use the `autotest` tool to help us get into a rhythm of red--green--refactor.
In this assignment we provided the specs for you; when designing your
own app, you'll write them yourself.

* *Code metrics* will give us insight into the quality of our code: is
it concise?  Is it factored in a way that minimizes the cost of making
changes and enhancements?  Does a particular class try to do too much
(or too little)?  We will use **CodeClimate** (among other tools) to
help us understand the answers.  We can check both quantitative metrics,
such as test coverage and complexity of a single method, and qualitative
ones, such as adherence to the *SOLID Principles* of object-oriented
design.

* *Refactoring* means modifying the structure of your code to improve
its quality (maintainability, readability, modifiability) while
preserving its behavior.  We will learn to identify *antipatterns* --
warning signs of deteriorating quality in your code -- and opportunities
to fix them, sometimes by applying *design patterns* that have emerged
as "templates" capturing an effective solution to a class of similar
problems. 

