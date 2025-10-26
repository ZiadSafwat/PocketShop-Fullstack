import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { CanActivateFn } from '@angular/router';

export const adminGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const token = localStorage.getItem('token');
  const role = localStorage.getItem('role');
  
  if (!token) {
    router.navigate(['/login']);
    return false;
  }
  
  if (role !== 'admin') {
    router.navigate(['/']);
    return false;
  }
  
  return true;
};