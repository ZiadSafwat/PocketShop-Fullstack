import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../services/auth';
import { LanguageService } from '../../../services/language';


@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './register.html',
  styleUrls: ['./register.scss']
})
export class Register  {
  private authService = inject(AuthService);
  private router = inject(Router);
  languageService = inject(LanguageService);

  email = '';
  password = '';
  confirmPassword = '';
  acceptedTerms = false;
  
  loading = signal(false);
  error = signal('');
  success = signal(false);
  formSubmitted = signal(false);

  translations = {
    create_account: { en: 'Create Account', ar: 'إنشاء حساب' },
    create_account_message: { en: 'Create your account to start shopping', ar: 'أنشئ حسابك لبدء التسوق' },
    email: { en: 'Email Address', ar: 'البريد الإلكتروني' },
    valid_email_required: { en: 'Please enter a valid email address', ar: 'يرجى إدخال بريد إلكتروني صحيح' },
    password: { en: 'Password', ar: 'كلمة المرور' },
    password_requirements: { en: 'Password must contain at least 8 characters, one uppercase letter, one lowercase letter, and one number', ar: 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل، حرف كبير واحد، حرف صغير واحد، ورقم واحد' },
    confirm_password: { en: 'Confirm Password', ar: 'تأكيد كلمة المرور' },
    passwords_must_match: { en: 'Passwords must match', ar: 'يجب أن تتطابق كلمات المرور' },
    i_agree: { en: 'I agree to the', ar: 'أوافق على' },
    terms_conditions: { en: 'terms and conditions', ar: 'الشروط والأحكام' },
    must_accept_terms: { en: 'You must accept the terms and conditions', ar: 'يجب أن توافق على الشروط والأحكام' },
    creating_account: { en: 'Creating Account...', ar: 'جاري إنشاء الحساب...' },
    registration_success: { en: 'Registration successful! Redirecting to login...', ar: 'تم التسجيل بنجاح! جاري التوجيه إلى صفحة تسجيل الدخول...' },
    or: { en: 'OR', ar: 'أو' },
    already_account: { en: 'Already have an account?', ar: 'لديك حساب بالفعل؟' },
    login_here: { en: 'Login here', ar: 'سجل الدخول هنا' }
  };

  isValidEmail(): boolean {
    const emailRegex = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i;
    return emailRegex.test(this.email);
  }

  isValidPassword(): boolean {
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return passwordRegex.test(this.password);
  }

  passwordsMatch(): boolean {
    return this.password === this.confirmPassword;
  }

  async onRegister(event: Event): Promise<void> {
    event.preventDefault();
    this.formSubmitted.set(true);
    this.error.set('');
    this.success.set(false);

     if (!this.isValidEmail() || !this.isValidPassword() || !this.passwordsMatch() || !this.acceptedTerms) {
      return;
    }

    this.loading.set(true);

    try {
      const userData = {
        email: this.email,
        avatar: '',
        role: 'user',
        password: this.password,
        passwordConfirm: this.confirmPassword
      };

      const success = await this.authService.register(userData);
      
      if (success) {
        this.success.set(true);
        
         setTimeout(() => {
          this.router.navigate(['/login']);
        }, 2000);
      } else {
        this.error.set(this.languageService.language() === 'en' 
          ? 'Registration failed. Please try again.' 
          : 'فشل التسجيل. يرجى المحاولة مرة أخرى.');
      }
    } catch (error: any) {
      console.error('Registration error:', error);
      
      if (error?.message) {
        this.error.set(error.message);
      } else {
        this.error.set(this.languageService.language() === 'en' 
          ? 'An error occurred during registration' 
          : 'حدث خطأ أثناء التسجيل');
      }
    } finally {
      this.loading.set(false);
    }
  }
}