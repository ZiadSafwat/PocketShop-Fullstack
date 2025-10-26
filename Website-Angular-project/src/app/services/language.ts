import { Injectable, signal, effect } from '@angular/core';

export type Language = 'en' | 'ar';

@Injectable({
  providedIn: 'root'
})
export class LanguageService {
  private currentLanguage = signal<Language>(this.getInitialLanguage());

  language = this.currentLanguage.asReadonly();

  constructor() {
    effect(() => {
      this.applyLanguage(this.currentLanguage());
    });
  }

  private getInitialLanguage(): Language {
    if (typeof window !== 'undefined') {
      const savedLang = localStorage.getItem('language') as Language;
      const browserLang = navigator.language.startsWith('ar') ? 'ar' : 'en';
      
      return savedLang || browserLang;
    }
    return 'en';
  }

  toggleLanguage(): void {
    const newLang = this.currentLanguage() === 'en' ? 'ar' : 'en';
    this.setLanguage(newLang);
  }

  setLanguage(lang: Language): void {
    this.currentLanguage.set(lang);
    if (typeof window !== 'undefined') {
      localStorage.setItem('language', lang);
    }
  }

  private applyLanguage(lang: Language): void {
    if (typeof document !== 'undefined') {
      document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = lang;
    }
  }

  translate(key: string, translations: any): string {
    return translations[key]?.[this.currentLanguage()] || key;
  }

  getDirection(): string {
    return this.currentLanguage() === 'ar' ? 'rtl' : 'ltr';
  }
}