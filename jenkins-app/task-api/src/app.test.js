const request = require('supertest');
  const { app, resetTasks } = require('./app');

  beforeEach(resetTasks);

  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  test('GET /tasks returns empty array initially', async () => {
    const res = await request(app).get('/tasks');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual([]);
  });

  test('POST /tasks creates a task', async () => {
    const res = await request(app).post('/tasks').send({ title: 'Buy milk' });
    expect(res.statusCode).toBe(201);
    expect(res.body).toMatchObject({ id: 1, title: 'Buy milk', done: false });
  });

  test('GET /tasks returns created tasks', async () => {
    await request(app).post('/tasks').send({ title: 'Task 1' });
    const res = await request(app).get('/tasks');
    expect(res.body).toHaveLength(1);
  });