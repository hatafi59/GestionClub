package dao;
import metier.entities.Club;
import java.util.List;

public interface IClubDao extends IGenericDao<Club> {
    List<Club> findByMotCle(String mc);
    //trouver le club par son id
    Club findById(int id);

}