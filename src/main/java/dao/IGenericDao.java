package dao;

import java.util.List;

public interface IGenericDao<T> {
    T save(T entity);
    T update(T entity);
    void delete(int id);
    T findById(int id);
    List<T> findAll();
}