import { Component, OnInit, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { environment } from '../environments/environment';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AsyncPipe, JsonPipe } from '@angular/common';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, AsyncPipe, JsonPipe],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit {
  private baseUrl = environment.apiUrl;
  public data!: Observable<any>;

  protected readonly title = signal('my-angular-app');

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.data = this.getData();
  }

  getData(): Observable<string[]> {
    return this.http.get<string[]>(this.baseUrl);
  }
}
