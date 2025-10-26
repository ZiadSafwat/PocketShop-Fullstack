import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AddProduct } from './add-product';

describe('AddProduct', () => {
  let component: AddProduct;
  let fixture: ComponentFixture<AddProduct>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AddProduct]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AddProduct);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
