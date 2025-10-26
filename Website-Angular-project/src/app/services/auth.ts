import { Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { User } from '../models/product.model';
import { ApiService } from './api';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUser = signal<User | null>(null);
  private isAuthenticated = signal<boolean>(false);

  user = this.currentUser.asReadonly();
  authenticated = this.isAuthenticated.asReadonly();

  constructor(
    private apiService: ApiService,
    private router: Router
  ) {
    this.checkAuthStatus();
  }

  private checkAuthStatus(): void {
    const token = localStorage.getItem('token');
    const userData = localStorage.getItem('user');
    
    if (token && userData) {
      this.isAuthenticated.set(true);
      this.currentUser.set(JSON.parse(userData));
    }
  }

  async login(email: string, password: string): Promise<boolean> {
    try {
      const response = await this.apiService.login(email, password).toPromise();
      if (response) {
        localStorage.setItem('token', response.token);
        localStorage.setItem('user', JSON.stringify(response.record));
        localStorage.setItem('role', response.record.role);
        localStorage.setItem('userId', response.record.id);
        
        this.isAuthenticated.set(true);
        this.currentUser.set(response.record);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  }

  register(userData: any): Promise<boolean> {
    return new Promise((resolve) => {
      this.apiService.register(userData).subscribe({
        next: () => {
          resolve(true);
        },
        error: (error) => {
          console.error('Registration error:', error);
          resolve(false);
        }
      });
    });
  }

  logout(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
    
    this.isAuthenticated.set(false);
    this.currentUser.set(null);
    
    this.router.navigate(['/login']);
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }

  getUserId(): string | null {
    return localStorage.getItem('userId');
  }

  getRole(): string | null {
    return localStorage.getItem('role');
  }

  isAdmin(): boolean {
    return this.getRole() === 'admin';
  }
}