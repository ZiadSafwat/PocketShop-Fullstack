import { Injectable, signal, effect } from '@angular/core';

export type Theme = 'light' | 'dark';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private currentTheme = signal<Theme>(this.getInitialTheme());

  theme = this.currentTheme.asReadonly();

  constructor() {
    effect(() => {
      this.applyTheme(this.currentTheme());
    });
  }

  private getInitialTheme(): Theme {
    if (typeof window !== 'undefined') {
      const savedTheme = localStorage.getItem('theme') as Theme;
      const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      
      return savedTheme || (systemPrefersDark ? 'dark' : 'light');
    }
    return 'light';
  }

  toggleTheme(): void {
    const newTheme = this.currentTheme() === 'light' ? 'dark' : 'light';
    this.currentTheme.set(newTheme);
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', newTheme);
    }
  }

  setTheme(theme: Theme): void {
    this.currentTheme.set(theme);
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', theme);
    }
  }

  private applyTheme(theme: Theme): void {
    if (typeof document !== 'undefined') {
      document.documentElement.setAttribute('data-bs-theme', theme);
      document.body.className = theme === 'dark' ? 'dark-theme' : 'light-theme';
    }
  }
}