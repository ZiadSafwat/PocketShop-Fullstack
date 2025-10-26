// import { Component, signal } from '@angular/core';
// import { RouterOutlet } from '@angular/router';

// @Component({
//   selector: 'app-root',
//   imports: [RouterOutlet],
//   templateUrl: './app.html',
//   styleUrl: './app.scss'
// })
// export class App {
//   protected readonly title = signal('ecommerce-app');
// }
// import { Component, inject, OnInit } from '@angular/core';
// import { CommonModule } from '@angular/common';
// import { RouterOutlet, RouterLink } from '@angular/router';
// import { ThemeService } from './services/theme.service';
// import { LanguageService } from './services/language.service';
// import { CartService } from './services/cart.service';

// @Component({
//   selector: 'app-root',
//   standalone: true,
//   imports: [CommonModule, RouterOutlet, RouterLink],
//   template: `
//     <nav class="navbar navbar-expand-lg" [class]="themeService.theme() === 'dark' ? 'navbar-dark bg-dark' : 'navbar-light bg-light'">
//       <div class="container">
//         <a class="navbar-brand" routerLink="/">E-Commerce</a>
        
//         <div class="navbar-nav ms-auto">
//           <button class="btn btn-outline-secondary me-2" (click)="themeService.toggleTheme()">
//             <i [class]="themeService.theme() === 'dark' ? 'fas fa-sun' : 'fas fa-moon'"></i>
//           </button>
          
//           <button class="btn btn-outline-secondary me-2" (click)="languageService.toggleLanguage()">
//             {{ languageService.language() === 'en' ? 'AR' : 'EN' }}
//           </button>
          
//           <a class="nav-link" routerLink="/cart">
//             <i class="fas fa-shopping-cart"></i>
//             <span class="badge bg-primary">{{ cartService.getCartCount() }}</span>
//           </a>
          
//           <a class="nav-link" routerLink="/wishlist">
//             <i class="fas fa-heart"></i>
//           </a>
//         </div>
//       </div>
//     </nav>
    
//     <main>
//       <router-outlet></router-outlet>
//     </main>
//   `
// })
// export class AppComponent implements OnInit {
//   themeService = inject(ThemeService);
//   languageService = inject(LanguageService);
//   cartService = inject(CartService);

//   ngOnInit() {
//     this.themeService.applyTheme(this.themeService.theme());
//     this.languageService.applyLanguage(this.languageService.language());
//   }
// }


import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from './services/theme';
import { LanguageService } from './services/language';
import { HeaderComponent } from './components/header/header';
import { Footer } from "./components/footer/footer";


@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, HeaderComponent, Footer],
  template: `
    <app-header></app-header>
    <main class="min-vh-100">
      <router-outlet></router-outlet>
    </main>
    <app-footer></app-footer>


  `
})
export class AppComponent implements OnInit {
  private themeService = inject(ThemeService);
  private languageService = inject(LanguageService);

  ngOnInit() {
    // Themes and language are automatically applied through services
  }
}