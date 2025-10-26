import { Component ,inject} from '@angular/core';
import { ThemeService } from '../../services/theme';

@Component({
  selector: 'app-footer',
  imports: [],
  templateUrl: './footer.html',
  styleUrl: './footer.scss',
})
export class Footer {
  themeService = inject(ThemeService);

}
