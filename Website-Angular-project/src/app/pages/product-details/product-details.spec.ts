import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ProductDetails } from './product-details';

describe('ProductDetails', () => {
  let component: ProductDetails;
  let fixture: ComponentFixture<ProductDetails>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ProductDetails]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ProductDetails);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
