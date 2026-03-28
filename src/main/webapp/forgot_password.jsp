<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <%-- SweetAlert2: used for success notification after password reset --%>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <title>Forgot Password | Palestine Relief</title>

    <%-- Google Fonts: Lora (headings) + DM Sans (body text) --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* ── CSS RESET ──────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        /* ── THEME VARIABLES ────────────────────────────────────
           Two themes: dark and light.
           Switching data-theme on <html> swaps all colors.
           Theme saved to localStorage key 'donorTheme'. */
        [data-theme="dark"]  { --bg:#0b0e14; --surface:#13171f; --surface2:#1a1f2b; --border:rgba(255,255,255,0.07); --text:#e6e8f0; --text2:#9ba3b8; --muted:#5a6278; --shadow:rgba(0,0,0,0.5); }
        [data-theme="light"] { --bg:#f2f4f8; --surface:#ffffff;  --surface2:#f7f8fc; --border:rgba(0,0,0,0.08);       --text:#181c2a; --text2:#4a5068; --muted:#9ba3b8; --shadow:rgba(0,0,0,0.08); }

        /* ── GLOBAL COLOR TOKENS ─────────────────────────────── */
        :root { --green:#1db954; --green-dim:rgba(29,185,84,0.12); --red:#e63946; --gold:#f4a261; }

        /* ── BODY ───────────────────────────────────────────────
           Centered vertically and horizontally.
           Two decorative ::before and ::after pseudo-elements:
             before = subtle green/gold radial gradient background glow
             after  = large Palestine flag watermark (opacity 3%) */
        body { font-family:'DM Sans',sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; align-items:center; justify-content:center; transition:background .25s,color .25s; position:relative; overflow-x:hidden; padding:40px 20px; }
        body::before { content:''; position:fixed; inset:0; background-image:radial-gradient(circle at 20% 30%,rgba(29,185,84,0.06) 0%,transparent 50%),radial-gradient(circle at 80% 70%,rgba(244,162,97,0.04) 0%,transparent 50%); pointer-events:none; }
        body::after  { content:'🇵🇸'; position:fixed; bottom:-40px; right:-20px; font-size:220px; opacity:.03; pointer-events:none; transform:rotate(-12deg); }

        /* ── THEME TOGGLE BUTTON ────────────────────────────────
           Fixed top-right button. Shows moon/sun emoji.
           Calls toggleTheme() to swap dark/light. */
        .theme-btn { position:fixed; top:20px; right:20px; width:36px; height:36px; border-radius:9px; background:var(--surface); border:1px solid var(--border); cursor:pointer; font-size:16px; display:flex; align-items:center; justify-content:center; transition:border-color .2s,background .25s; z-index:10; }
        .theme-btn:hover { border-color:var(--green); }

        /* ── CARD ───────────────────────────────────────────────
           Centered white/dark card containing the form.
           Max-width 420px. Fades in with fadeUp animation. */
        .card { background:var(--surface); border:1px solid var(--border); border-radius:16px; padding:40px 36px; width:100%; max-width:420px; box-shadow:0 8px 40px var(--shadow); animation:fadeUp .45s ease both; transition:background .25s,border-color .25s; }

        /* ── BRAND ──────────────────────────────────────────────
           Centered "Palestine Relief" brand name at top of card */
        .brand { display:flex; align-items:center; gap:10px; justify-content:center; margin-bottom:28px; }
        .brand-icon { width:38px; height:38px; border-radius:10px; background:var(--green-dim); border:1px solid rgba(29,185,84,0.25); display:flex; align-items:center; justify-content:center; font-size:19px; }
        .brand-name { font-family:'Lora',serif; font-size:19px; font-weight:600; }
        .brand-name span { color:var(--green); }

        /* ── CARD TITLE AND SUBTITLE ────────────────────────────
           Title: "Reset Password"
           Subtitle changes based on current step (1 or 2) */
        .card-title { font-family:'Lora',serif; font-size:22px; font-weight:600; text-align:center; margin-bottom:4px; }
        .card-sub   { font-size:13px; color:var(--muted); text-align:center; margin-bottom:28px; line-height:1.6; }

        /* ── STEP INDICATOR ─────────────────────────────────────
           Two-step progress bar at top of form:
           Step 1: Identify | Step 2: Reset
           Active step = green underline. Done step = faded green. */
        .step-indicator { display:flex; align-items:center; gap:0; margin-bottom:28px; }
        .step { flex:1; text-align:center; font-size:12px; font-weight:600; padding:8px; border-bottom:2px solid var(--border); color:var(--muted); transition:all .2s; }
        .step.active { color:var(--green); border-bottom-color:var(--green); }
        .step.done   { color:var(--green); border-bottom-color:var(--green); opacity:.5; }

        /* ── FORM FIELDS ────────────────────────────────────────
           Standard label + input pairs with green focus ring.
           .valid = green border (passes validation)
           .invalid = red border (fails validation) */
        .field { display:flex; flex-direction:column; gap:6px; margin-bottom:14px; }
        .field label { font-size:11.5px; font-weight:600; text-transform:uppercase; letter-spacing:.7px; color:var(--muted); }
        .field input { background:var(--surface2); border:1px solid var(--border); color:var(--text); padding:11px 14px; border-radius:8px; font-size:14px; font-family:inherit; outline:none; width:100%; transition:border-color .18s,box-shadow .18s,background .25s; }
        .field input::placeholder { color:var(--muted); }
        .field input:focus   { border-color:var(--green); box-shadow:0 0 0 3px rgba(29,185,84,0.1); }
        .field input.valid   { border-color:var(--green); }
        .field input.invalid { border-color:var(--red);   box-shadow:0 0 0 3px rgba(230,57,70,0.08); }

        /* ── SECURITY QUESTION BOX ──────────────────────────────
           Displays the user's security question in Step 2.
           Retrieved from DB by ForgotPasswordServlet in Step 1. */
        .question-box { background:var(--surface2); border:1px solid rgba(29,185,84,0.2); border-radius:8px; padding:12px 16px; margin-bottom:14px; font-size:13.5px; color:var(--text2); line-height:1.5; }
        .question-box strong { display:block; font-size:11px; text-transform:uppercase; letter-spacing:.7px; color:var(--green); margin-bottom:5px; }

        /* ── PASSWORD FIELD WITH EYE TOGGLE ────────────────────
           Eye button inside the password field.
           Clicking toggles between password/text type via togglePw(). */
        .pw-wrap { position:relative; }
        .pw-wrap input { padding-right:42px; }
        .pw-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%); cursor:pointer; font-size:15px; opacity:.5; transition:opacity .18s; background:none; border:none; padding:0; }
        .pw-eye:hover { opacity:1; }

        /* ── PASSWORD REQUIREMENTS PANEL ────────────────────────
           Hidden by default. Shown when user starts typing password.
           Each requirement turns green with ✓ when met.
           Checked live by checkPassword() JS function. */
        .pw-reqs { background:var(--surface2); border:1px solid var(--border); border-radius:8px; padding:12px 14px; margin-top:6px; display:none; }
        .pw-reqs.visible { display:block; }
        .pw-reqs-title { font-size:11px; text-transform:uppercase; letter-spacing:.7px; color:var(--muted); margin-bottom:8px; font-weight:600; }
        .req { display:flex; align-items:center; gap:8px; font-size:12.5px; color:var(--muted); padding:3px 0; transition:color .2s; }
        .req-icon { font-size:13px; width:16px; text-align:center; flex-shrink:0; }
        .req.met { color:var(--green); }

        /* ── PASSWORD MATCH MESSAGE ─────────────────────────────
           Shown below confirm password field.
           Green "✓ Passwords match" or red "✗ Passwords do not match"
           Checked live by checkConfirm() JS function. */
        .match-msg { font-size:12px; margin-top:5px; display:none; }
        .match-msg.ok  { color:var(--green); display:block; }
        .match-msg.bad { color:var(--red);   display:block; }

        /* ── SUBMIT BUTTON ──────────────────────────────────────
           Disabled until all password requirements are met
           and both passwords match. Enabled by updateSubmit(). */
        .btn-submit { width:100%; background:var(--green); color:#051a0d; border:none; padding:12px; border-radius:8px; font-size:14.5px; font-weight:700; cursor:pointer; font-family:inherit; transition:opacity .18s,transform .1s; margin-top:6px; }
        .btn-submit:hover    { opacity:.88; transform:translateY(-1px); }
        .btn-submit:active   { transform:translateY(0); }
        .btn-submit:disabled { opacity:.4; cursor:not-allowed; transform:none; }

        /* ── ERROR BOX ──────────────────────────────────────────
           Red box shown when ForgotPasswordServlet redirects back
           with an ?error= parameter (e.g. notfound, wronganswer).
           Shakes on appear to draw attention. */
        .error-box { display:flex; align-items:center; gap:8px; background:rgba(230,57,70,0.08); border:1px solid rgba(230,57,70,0.25); border-radius:8px; padding:10px 14px; margin-bottom:16px; animation:shake .35s ease; }
        .error-box span { font-size:13px; color:var(--red); }

        /* ── FOOTER ─────────────────────────────────────────────
           "Back to Sign In" link below the form */
        .divider { display:flex; align-items:center; gap:10px; margin:20px 0; color:var(--muted); font-size:12px; }
        .divider::before, .divider::after { content:''; flex:1; height:1px; background:var(--border); }
        .card-footer { text-align:center; font-size:13px; color:var(--muted); }
        .card-footer a { color:var(--green); text-decoration:none; font-weight:500; }
        .card-footer a:hover { text-decoration:underline; }

        /* ── ANIMATIONS ─────────────────────────────────────────
           fadeUp: card appears with upward slide on page load
           shake: error box shakes when it appears */
        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:none;} }
        @keyframes shake  { 0%,100%{transform:translateX(0);}25%{transform:translateX(-6px);}75%{transform:translateX(6px);} }
    </style>
</head>
<body>

<%-- Theme toggle button: fixed top-right, switches dark/light mode --%>
<button class="theme-btn" onclick="toggleTheme()" id="themeBtn">🌙</button>

<%-- ── SERVER-SIDE: READ URL PARAMETERS ──────────────────────────
     ForgotPasswordServlet redirects back to this page with parameters:
       step     = "1" (username entry) or "2" (answer + new password)
       username = the entered username (carried through steps)
       question = the security question key (e.g. "pet", "city")
       error    = error code if something went wrong

     questionMap maps short key → full question text
     e.g. "pet" → "What was the name of your first pet?" --%>
<%
    String step     = request.getParameter("step");
    String username = request.getParameter("username");
    String question = request.getParameter("question");
    String error    = request.getParameter("error");
    if (step == null) step = "1"; // Default to step 1 on first visit

    // Map security question keys to their full display text
    java.util.Map<String,String> questionMap = new java.util.LinkedHashMap<>();
    questionMap.put("pet",    "What was the name of your first pet?");
    questionMap.put("city",   "What city were you born in?");
    questionMap.put("mother", "What is your mother's maiden name?");
    questionMap.put("school", "What was the name of your primary school?");
    questionMap.put("friend", "What is the name of your childhood best friend?");

    // Look up the full question text from the key, fallback to key itself
    String questionText = questionMap.getOrDefault(question != null ? question : "", question != null ? question : "");
%>

<div class="card">

    <%-- Brand name at top of card --%>
    <div class="brand">
        <div class="brand-name">Palestine <span>Relief</span></div>
    </div>

    <%-- Title and step-specific subtitle --%>
    <div class="card-title">Reset Password</div>
    <div class="card-sub">
        <% if("1".equals(step)) { %>Verify your identity to reset your password.<% } %>
        <% if("2".equals(step)) { %>Answer your security question and set a new password.<% } %>
    </div>

    <%-- Step indicator: Step 1 active → Step 2 inactive (or vice versa) --%>
    <div class="step-indicator">
        <div class="step <%= "1".equals(step) ? "active" : "done" %>">① Identify</div>
        <div class="step <%= "2".equals(step) ? "active" : "" %>">② Reset</div>
    </div>

    <%-- ── ERROR BOX ────────────────────────────────────────────
         Show error message if ForgotPasswordServlet redirected
         back with an ?error= parameter.
         Each error code maps to a human-readable message. --%>
    <%
        String errorMsg = null;
        if      ("nousername".equals(error))  errorMsg = "Please enter your username.";
        else if ("notfound".equals(error))    errorMsg = "No account found with that username.";
        else if ("wronganswer".equals(error)) errorMsg = "Incorrect answer. Please try again.";
        else if ("mismatch".equals(error))    errorMsg = "Passwords do not match.";
        else if ("weak".equals(error))        errorMsg = "Password does not meet the requirements.";
        else if ("missing".equals(error))     errorMsg = "Please fill in all fields.";
        else if ("database".equals(error))    errorMsg = "A database error occurred. Please try again.";
        if (errorMsg != null) {
    %>
    <div class="error-box"><span><%= errorMsg %></span></div>
    <% } %>

    <%-- ── STEP 1: USERNAME FORM ─────────────────────────────────
         Simple form with one input: username.
         Submits POST to ForgotPasswordServlet with step=1.
         Servlet looks up the user in DB, retrieves security question key,
         then redirects back to this page with step=2&username=X&question=Y --%>
    <% if ("1".equals(step)) { %>
    <form action="forgotPassword" method="post">
        <input type="hidden" name="step" value="1">
        <div class="field">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username" required autofocus>
        </div>
        <button type="submit" class="btn-submit">Find My Account</button>
    </form>

    <%-- ── STEP 2: SECURITY ANSWER + NEW PASSWORD FORM ────────────
         Shown after username is found.
         Fields: security answer | new password | confirm new password
         Submits POST to ForgotPasswordServlet with step=2.
         Servlet verifies answer with BCrypt.checkpw(), then if correct,
         hashes new password with BCrypt.hashpw() and updates DB.
         On success → redirects to forgot_password.jsp?msg=pwreset --%>
    <% } else if ("2".equals(step)) { %>
    <form action="forgotPassword" method="post" id="resetForm">
        <input type="hidden" name="step" value="2">
        <%-- Pass username forward so servlet knows which account to update --%>
        <input type="hidden" name="username" value="<%= username != null ? username : "" %>">

        <%-- Show the user's security question (retrieved from DB in Step 1) --%>
        <div class="question-box">
            <strong>Your Security Question</strong>
            <%= questionText %>
        </div>

        <%-- Security answer field — compared against BCrypt hash in DB --%>
        <div class="field">
            <label>Your Answer</label>
            <input type="text" name="answer" placeholder="Answer (case-insensitive)" required>
        </div>

        <%-- New password field with:
             - Eye toggle button (show/hide password)
             - Live requirements panel (shown on first keystroke)
             - checkPassword() validates each requirement in real-time --%>
        <div class="field">
            <label>New Password</label>
            <div class="pw-wrap">
                <input type="password" name="newPassword" id="pwInput"
                       placeholder="Create new password" required oninput="checkPassword()">
                <button type="button" class="pw-eye" onclick="togglePw('pwInput','eye1')" id="eye1">👁️</button>
            </div>
            <%-- Password requirements panel — hidden until user starts typing --%>
            <div class="pw-reqs" id="pwReqs">
                <div class="pw-reqs-title">Password must have:</div>
                <div class="req unmet" id="req-len">  <span class="req-icon">○</span> At least 8 characters</div>
                <div class="req unmet" id="req-upper"><span class="req-icon">○</span> One uppercase letter</div>
                <div class="req unmet" id="req-lower"><span class="req-icon">○</span> One lowercase letter</div>
                <div class="req unmet" id="req-num">  <span class="req-icon">○</span> One number</div>
                <div class="req unmet" id="req-sym">  <span class="req-icon">○</span> One special character</div>
            </div>
        </div>

        <%-- Confirm password field with:
             - Eye toggle button
             - Live match indicator (checkConfirm() runs on every keystroke) --%>
        <div class="field">
            <label>Confirm New Password</label>
            <div class="pw-wrap">
                <input type="password" name="confirmNew" id="confirmInput"
                       placeholder="Repeat new password" required oninput="checkConfirm()">
                <button type="button" class="pw-eye" onclick="togglePw('confirmInput','eye2')" id="eye2">👁️</button>
            </div>
            <%-- Shows green "✓ match" or red "✗ no match" --%>
            <div class="match-msg" id="matchMsg"></div>
        </div>

        <%-- Submit button: disabled until all requirements met + passwords match
             Enabled by updateSubmit() when pwAllMet && confirmOk are both true --%>
        <button type="submit" class="btn-submit" id="submitBtn" disabled>Reset Password</button>
    </form>
    <% } %>

    <%-- Back to login link --%>
    <div class="divider">or</div>
    <div class="card-footer"><a href="login.jsp">Back to Sign In</a></div>
</div>

<script>
    var html = document.documentElement;

    /* ── THEME ──────────────────────────────────────────────────
       On load: read saved theme from localStorage (default: dark).
       Shares 'donorTheme' key with donor_dashboard.jsp so theme
       stays consistent across both pages. */
    (function() {
        var saved = localStorage.getItem('donorTheme') || 'dark';
        applyTheme(saved);
    })();

    function applyTheme(theme) {
        html.setAttribute('data-theme', theme);
        document.getElementById('themeBtn').textContent = theme === 'dark' ? '☀️' : '🌙';
        localStorage.setItem('donorTheme', theme);
    }

    function toggleTheme() {
        applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
    }

    /* ── PASSWORD SHOW/HIDE ─────────────────────────────────────
       Toggles password input between type="password" and type="text".
       Eye emoji changes to reflect current state. */
    function togglePw(inputId, btnId) {
        var input = document.getElementById(inputId);
        var btn   = document.getElementById(btnId);
        input.type = input.type === 'password' ? 'text' : 'password';
        btn.textContent = input.type === 'password' ? '👁️' : '🙈';
    }

    /* ── PASSWORD REQUIREMENTS CHECKER ─────────────────────────
       5 rules checked live as user types in the new password field.
       Each rule has a corresponding div that turns green with ✓ when met.
       Also updates the password input border (valid/invalid).
       Calls updateSubmit() after each check. */
    var rules = {
        'req-len':   function(v){ return v.length >= 8; },          // Min 8 chars
        'req-upper': function(v){ return /[A-Z]/.test(v); },        // One uppercase
        'req-lower': function(v){ return /[a-z]/.test(v); },        // One lowercase
        'req-num':   function(v){ return /\d/.test(v); },           // One number
        'req-sym':   function(v){ return /[^a-zA-Z0-9]/.test(v); }, // One special char
    };
    var pwAllMet = false, confirmOk = false;

    function checkPassword() {
        var val  = document.getElementById('pwInput').value;
        var reqs = document.getElementById('pwReqs');

        // Show requirements panel only when user starts typing
        reqs.classList.toggle('visible', val.length > 0);

        var allMet = true;
        for (var id in rules) {
            var met = rules[id](val);
            var el  = document.getElementById(id);
            // Toggle green "met" or grey "unmet" class
            el.className = 'req ' + (met ? 'met' : 'unmet');
            // Swap circle to checkmark when requirement is met
            el.querySelector('.req-icon').textContent = met ? '✓' : '○';
            if (!met) allMet = false;
        }
        pwAllMet = allMet;

        // Update border color of password input
        document.getElementById('pwInput').className =
            val.length === 0 ? '' : (allMet ? 'valid' : 'invalid');

        // Re-check confirm field if it already has a value
        if (document.getElementById('confirmInput').value.length > 0) checkConfirm();
        updateSubmit();
    }

    /* ── CONFIRM PASSWORD MATCH CHECKER ────────────────────────
       Compares new password vs confirm password on every keystroke.
       Shows green match or red no-match message below confirm field.
       Calls updateSubmit() to enable/disable submit button. */
    function checkConfirm() {
        var pw  = document.getElementById('pwInput').value;
        var cfm = document.getElementById('confirmInput').value;
        var msg = document.getElementById('matchMsg');
        var inp = document.getElementById('confirmInput');

        if (cfm.length === 0) {
            // Empty — no message shown
            msg.className = 'match-msg'; inp.className = ''; confirmOk = false;
        } else if (pw === cfm) {
            // Match — green message
            msg.className = 'match-msg ok'; msg.textContent = '✓ Passwords match';
            inp.className = 'valid'; confirmOk = true;
        } else {
            // No match — red message
            msg.className = 'match-msg bad'; msg.textContent = '✗ Passwords do not match';
            inp.className = 'invalid'; confirmOk = false;
        }
        updateSubmit();
    }

    /* ── SUBMIT BUTTON STATE ────────────────────────────────────
       Submit button is only enabled when:
         pwAllMet = true (all 5 password requirements passed)
         confirmOk = true (both passwords match)
       Prevents form submission with invalid password. */
    function updateSubmit() {
        var btn = document.getElementById('submitBtn');
        if (btn) btn.disabled = !(pwAllMet && confirmOk);
    }

    /* ── SUCCESS ALERT AFTER PASSWORD RESET ────────────────────
       When ForgotPasswordServlet redirects back with ?msg=pwreset,
       show a SweetAlert2 success modal.
       On confirm → redirect to login.jsp.
       Clean URL after so refreshing doesn't re-show the alert. */
    (function() {
        var params = new URLSearchParams(window.location.search);
        if (params.get('msg') === 'pwreset') {
            var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            Swal.fire({
                background: isDark ? '#13171f' : '#ffffff',
                color:      isDark ? '#e6e8f0' : '#181c2a',
                icon: 'success',
                iconColor: '#1db954',
                title: 'Password Reset!',
                html: '<p style="font-size:14px;line-height:1.6;">Your password has been updated successfully.<br>Please sign in with your new password.</p>',
                confirmButtonColor: '#1db954',
                confirmButtonText: 'Go to Sign In',
            }).then(function() {
                window.location.href = 'login.jsp'; // Redirect to login after clicking OK
            });
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    })();
</script>
</body>
</html>