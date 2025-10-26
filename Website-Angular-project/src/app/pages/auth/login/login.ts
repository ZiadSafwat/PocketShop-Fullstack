import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../services/auth';
import { LanguageService } from '../../../services/language';


@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrls: ['./login.scss']
})
export class Login  {
  private authService = inject(AuthService);
  private router = inject(Router);
  languageService = inject(LanguageService);

  email = '';
  password = '';
  loading = signal(false);
  error = signal('');
  formSubmitted = signal(false);

  translations = {
    sign_in: { en: 'Sign In', ar: 'تسجيل الدخول' },
    sign_in_message: { en: 'Sign in to your account', ar: 'سجل الدخول إلى حسابك' },
    email: { en: 'Email Address', ar: 'البريد الإلكتروني' },
    email_required: { en: 'Please enter a valid email address', ar: 'يرجى إدخال بريد إلكتروني صحيح' },
    password: { en: 'Password', ar: 'كلمة المرور' },
    password_required: { en: 'Password must be at least 6 characters', ar: 'يجب أن تكون كلمة المرور 6 أحرف على الأقل' },
    remember_me: { en: 'Remember me', ar: 'تذكرني' },
    forgot_password: { en: 'Forgot password?', ar: 'نسيت كلمة المرور؟' },
    signing_in: { en: 'Signing in...', ar: 'جاري تسجيل الدخول...' },
    or: { en: 'OR', ar: 'أو' },
    no_account: { en: "Don't have an account?", ar: 'ليس لديك حساب؟' },
    register_here: { en: 'Register here', ar: 'سجل هنا' }
  };

  async onLogin(event: Event): Promise<void> {
    event.preventDefault();
    this.formSubmitted.set(true);
    this.error.set('');

 
    if (!this.email || !this.password || this.password.length < 6) {
      return;
    }

    this.loading.set(true);

    try {
      const success = await this.authService.login(this.email, this.password);
      
      if (success) {
        this.router.navigate(['/']);
      } else {
        this.error.set(this.languageService.language() === 'en' 
          ? 'Invalid email or password' 
          : 'البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
    } catch (error) {
      console.error('Login error:', error);
      this.error.set(this.languageService.language() === 'en' 
        ? 'An error occurred during login' 
        : 'حدث خطأ أثناء تسجيل الدخول');
    } finally {
      this.loading.set(false);
    }
  }
}