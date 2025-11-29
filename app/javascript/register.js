function initializePasswordValidation() {
    const passwordInput = document.querySelector('#password');
    const confirmPasswordInput = document.querySelector('#confirm_password'); // Corrected the ID selector
    const passwordStrength = document.querySelector('#password-strength');
    const togglePassword = document.querySelector('#togglePassword');
    const confirmPasswordCheck = document.querySelector('#confirm-password-check');

    function checkPasswordStrength(password) {
        let strength = 0;
        if (password.length >= 8) strength++;
        if (password.match(/[a-z]+/)) strength++;
        if (password.match(/[A-Z]+/)) strength++;
        if (password.match(/[0-9]+/)) strength++;
        if (password.match(/[$@#&!]+/)) strength++;
        return strength;
    }

    function updatePasswordStrength(strength) {
        const colors = ['#ff4d4d', '#ffa64d', '#b8b841', '#4dff4d', '#21a753'];
        const labels = ['Very Weak', 'Weak', 'Medium', 'Strong', 'Very Strong'];
        
        passwordStrength.style.backgroundColor = colors[strength - 1];
        passwordStrength.textContent = labels[strength - 1];
        passwordStrength.style.opacity = '1';
        passwordStrength.style.transform = 'translateY(0)';
    }

    if (togglePassword) {
        togglePassword.addEventListener('click', function() {
            const type = passwordInput.type === 'password' ? 'text' : 'password';
            passwordInput.type = type;
            this.classList.toggle('bx-hide');
            this.classList.toggle('bx-show');
        });
    }

    if (passwordInput) {
        passwordStrength.style.position = 'absolute';
        passwordStrength.style.right = '40px';
        passwordStrength.style.top = '30%';
        passwordStrength.style.transform = 'translateY(-50%)';
        passwordStrength.style.fontSize = '12px';
        passwordStrength.style.padding = '3px 8px';
        passwordStrength.style.borderRadius = '25px';
        passwordStrength.style.zIndex = '10';
        
        passwordInput.addEventListener('input', function() {
            const strength = checkPasswordStrength(this.value);
            updatePasswordStrength(strength);
        });

        passwordInput.addEventListener('blur', function() {
            if (!this.value) {
                passwordStrength.style.opacity = '0';
            }
        });
    }

    if (confirmPasswordInput && passwordInput) {
        confirmPasswordCheck.style.position = 'absolute';
        confirmPasswordCheck.style.right = '40px';
        confirmPasswordCheck.style.top = '50%';
        confirmPasswordCheck.style.transform = 'translateY(-50%)';
        confirmPasswordCheck.style.fontSize = '12px';
        confirmPasswordCheck.style.padding = '2px 5px';
        confirmPasswordCheck.style.borderRadius = '25px';
        confirmPasswordCheck.style.zIndex = '10';
        
        confirmPasswordInput.addEventListener('input', function() {
            if (this.value === passwordInput.value) {
                confirmPasswordCheck.innerHTML = '✓';
                confirmPasswordCheck.style.backgroundColor = '#21a753';
            } else {
                confirmPasswordCheck.innerHTML = '✗';
                confirmPasswordCheck.style.backgroundColor = '#ff4d4d';
            }
            confirmPasswordCheck.style.opacity = '1';
        });

        confirmPasswordInput.addEventListener('blur', function() {
            if (!this.value) {
                confirmPasswordCheck.style.opacity = '0';
            }
        });
    }

    const emailSuggestionContainer = document.querySelector('.overflow-x-auto');
    if (emailSuggestionContainer) {
        emailSuggestionContainer.addEventListener('wheel', function(event) {
            if (event.deltaY !== 0) {
                event.preventDefault();
                emailSuggestionContainer.scrollLeft += event.deltaY + event.deltaX;
            }
        });
    }

    const emailButtons = document.querySelectorAll('.overflow-x-auto button');
    const emailInput = document.getElementById('email');
    emailButtons.forEach(button => {
        button.addEventListener('click', function() {
            emailInput.value = emailInput.value.split('@')[0] + this.textContent;
        });
    });
}

document.addEventListener('DOMContentLoaded', initializePasswordValidation);

initializePasswordValidation();