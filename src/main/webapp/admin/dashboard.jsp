<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="web.AdminController.ClubStat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.stream.Collectors" %>

<%
    String sortBy = (String) request.getAttribute("sortBy"); // NOUVEAU
    if (sortBy == null) sortBy = "membres";
    // Données du Controller
    List<ClubStat> clubStats = (List<ClubStat>) request.getAttribute("clubStats");
    List<Utilisateur> listeUtilisateurs = (List<Utilisateur>) request.getAttribute("listeUtilisateurs");
    int sizeTotalUtilisateurs = (int) request.getAttribute("sizeTotalUtilisateurs");
    List<Club> tousClubs = (List<Club>) request.getAttribute("tousClubs"); // Pour la liste déroulante
    String motCle = (String) request.getAttribute("motCleRecherche");
    String tab = request.getParameter("tab");

    if (clubStats == null) clubStats = List.of();
    if (listeUtilisateurs == null) listeUtilisateurs = List.of();
    if (tousClubs == null) tousClubs = List.of();
    if (motCle == null) motCle = "";

    // Calcul des statistiques globales (à refaire car on ne peut pas appeler le service ici)
    int totalClubs = tousClubs.size();
    // On suppose que listeUtilisateurs contient TOUS les utilisateurs si pas de recherche
    int totalMembresActifs = clubStats.stream().mapToInt(s -> s.nombreMembresActifs).sum();
    int totalEvents = clubStats.stream().mapToInt(s -> s.nombreEvenements).sum();

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    DecimalFormat df = new DecimalFormat("#,##0");

%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Admin - Gestion Clubs</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        /* --- THÈME ADMIN (Rouge/Noir/Gold) --- */
        :root {
            --a-primary: #dc3545; /* Rouge Danger/Admin */
            --a-dark: #212529;
            --a-light: #f8f9fa;
            --a-success: #28a745;
            --a-warning: #ffc107;
            --primary: #095bca;      /* Bleu principal */
            --secondary: #2172ac;    /* Bleu secondaire */
            --accent: #ff6b6b;       /* Accent rouge/corail */
            --success: #00b894;      /* Vert succès */
            --text-dark: #2d3436;
            --text-light: #636e72;
            --bg-light: #f9f9f9;
            --white: #ffffff;
            --shadow: 0 10px 20px rgba(0,0,0,0.08);
            --radius: 16px;
        }

        body { font-family: 'Poppins', sans-serif; background: var(--a-light); margin: 0; color: var(--a-dark); }
        .hero-admin {
            background: linear-gradient(135deg, var(--a-dark), #495057);
            color: white; padding: 10px 20px; text-align: center;
            border-radius: 0 0 40px 40px; margin-bottom: 10px;
        }
        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px 50px; }
        .tab-navigation {
            display: flex;
            justify-content: start;
            gap: 20px;
            margin-bottom: 40px;
            margin-top: 20px;
        }

        .tab-btn {
            padding: 8px 15px;
            background-color: white;
            color: var(--text-dark);
            text-decoration: none;
            border-radius: 4px;
            border: 2px solid var(--text-dark);
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: opacity 0.3s;
        }

        .tab-btn svg {
            width: 20px;
            height: 20px;
            fill: currentColor;
        }

        /* État Actif des Onglets */
        .tab-btn.active {
            background: var(--text-dark);
            border: 2px solid var(--text-dark);
            color: white;
            transform: translateY(-2px);
        }

        .tab-btn:hover:not(.active) {
            background-color: #e9ecef;
            color: var(--primary);
        }
        .section {
            display: none;
            animation: fadeIn 0.5s ease;
        }
        .section.active {
            display: block;
        }        @keyframes fadeIn { from{opacity:0; transform:translateY(10px)} to{opacity:1; transform:translateY(0)} }

        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; background: white; border-left: 5px solid var(--a-success); box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .alert-error { border-left: 5px solid var(--a-primary); background-color: #f8d7da; color: #721c24; }

        /* Stats Cards */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 40px; }
        .stat-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); text-align: center; border-bottom: 5px solid var(--a-primary); }
        .stat-card h4 { font-size: 2.5rem; color: var(--accent); margin-bottom: 5px; }
        .stat-card p { font-weight: 600; color: var(--a-dark); opacity: 0.7; }

        /* Tables */
        .admin-table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.05); margin-top: 20px; }
        .admin-table th { background: var(--text-dark); color: white; padding: 15px; text-align: left; }
        .admin-table td { padding: 15px; border-bottom: 1px solid #eee; }
        .btn-action { padding: 6px 12px; border-radius: 5px; text-decoration: none; border: none; cursor: pointer; font-size: 0.9em; color: white; display: inline-block; }
        .btn-delete { background: var(--a-primary); }
        .btn-assign { background: var(--a-warning); }

        /* Formulaire */
        .form-box { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; margin-bottom: 10px; }
        .btn-submit { background: var(--a-success); color: white; width: 100%; padding: 12px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }

        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    </style>
</head>
<body>

<jsp:include page="/common/header.jsp" />

<div class="hero-admin">
    <h1>Super Administrateur</h1>
    <p>Gestion centrale de la plateforme ENSA Clubs</p>
</div>

<div class="container">

    <% if ("club_cree".equals(msg) || "club_supprime".equals(msg) || "president_assigne".equals(msg) || "utilisateur_supprime".equals(msg)) { %>
    <div class="alert">Notification : Opération effectuée avec succès.</div>
    <% } %>
    <% if (error != null) { %>
    <div class="alert alert-error">Erreur : L'opération a échoué.</div>
    <% } %>


    <div class="tab-navigation">
        <button class="tab-btn active" onclick="switchTab('stats')" id="btn-stats">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M16.604 11.048a5.67 5.67 0 0 0 .751-3.44c-.179-1.784-1.175-3.361-2.803-4.44l-1.105 1.666c1.119.742 1.8 1.799 1.918 2.974a3.693 3.693 0 0 1-1.072 2.986l-1.192 1.192 1.618.475C18.951 13.701 19 17.957 19 18h2c0-1.789-.956-5.285-4.396-6.952z"></path><path d="M9.5 12c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2zm1.5 7H8c-3.309 0-6 2.691-6 6v1h2v-1c0-2.206 1.794-4 4-4h3c2.206 0 4 1.794 4 4v1h2v-1c0-3.309-2.691-6-6-6z"></path></svg>
            Statistiques
        </button>
        <button class="tab-btn" onclick="switchTab('management')" id="btn-management">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19 4h-2V2h-2v2H9V2H7v2H5c-1.103 0-2 .897-2 2v14c0 1.103.897 2 2 2h14c1.103 0 2-.897 2-2V6c0-1.103-.897-2-2-2zm.002 16H5V8h14l.002 12z"></path></svg>
            Gestion Avancée
        </button>
    </div>





    <div id="stats" class="section active">
        <h3 style="color: var(--a-dark);">Vue d'ensemble</h3>
        <div class="stats-grid">
            <div class="stat-card"><h4><%= df.format(totalClubs) %></h4><p>Clubs Actifs</p></div>
            <div class="stat-card" style="border-bottom-color: var(--a-success);"><h4><%= df.format(sizeTotalUtilisateurs) %></h4><p>Total Utilisateurs</p></div>
            <div class="stat-card" style="border-bottom-color: var(--a-warning);"><h4><%= df.format(totalMembresActifs) %></h4><p>Adhésions Acceptées</p></div>
            <div class="stat-card" style="border-bottom-color: var(--a-dark);"><h4><%= df.format(totalEvents) %></h4><p>Événements Créés</p></div>
        </div>


        <h3 style="color: var(--a-dark);">
            Top Clubs
            <small style="font-size: 0.9em; color:#666;">(Trié par :
                <%
                    String sortName = "Membres Actifs";
                    if("evenements".equals(sortBy)) sortName = "Événements";
                    else if("en_attente".equals(sortBy)) sortName = "Adhésions en Attente";
                    else if("refusees".equals(sortBy)) sortName = "Adhésions Refusées";
                %>
                <%= sortName %>)
            </small>
        </h3>

        <table class="admin-table">
            <thead>
            <tr>
                <th>Club</th>
                <th><a href="${pageContext.request.contextPath}/admin?sortBy=membres&tab=stats" style="color:white; text-decoration: <%= "membres".equals(sortBy) ? "underline" : "none" %>;">Membres Actifs</a></th>
                <th><a href="${pageContext.request.contextPath}/admin?sortBy=evenements&tab=stats" style="color:white; text-decoration: <%= "evenements".equals(sortBy) ? "underline" : "none" %>;">Événements</a></th>
                <th><a href="${pageContext.request.contextPath}/admin?sortBy=en_attente&tab=stats" style="color:white; text-decoration: <%= "en_attente".equals(sortBy) ? "underline" : "none" %>;">Demandes En Attente</a></th>
                <th><a href="${pageContext.request.contextPath}/admin?sortBy=refusees&tab=stats" style="color:white; text-decoration: <%= "refusees".equals(sortBy) ? "underline" : "none" %>;">Adhésions Refusées</a></th>
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < Math.min(7, clubStats.size()); i++) {
                ClubStat cs = clubStats.get(i);
            %>
            <tr>
                <td><strong><%= cs.club.getNom() %></strong></td>
                <td style="font-weight: bold; color: <%= "membres".equals(sortBy) ? "var(--a-primary)" : "var(--a-success)" %>;">
                    <%= df.format(cs.nombreMembresActifs) %>
                </td>
                <td style="color: <%= "evenements".equals(sortBy) ? "var(--a-primary)" : "var(--a-dark)" %>;">
                    <%= df.format(cs.nombreEvenements) %>
                </td>
                <td style="color: <%= "en_attente".equals(sortBy) ? "var(--a-primary)" : "var(--a-warning)" %>;">
                    <%= df.format(cs.nombreAdhesionsEnAttente) %>
                </td>
                <td style="color: <%= "refusees".equals(sortBy) ? "var(--a-primary)" : "var(--a-primary)" %>;">
                    <%= df.format(cs.nombreAdhesionsRefusees) %>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% if (clubStats.isEmpty()) { %> <p>Aucun club à afficher.</p> <% } %>
    </div>




    <div id="management" class="section">

        <div class="grid-2">
            <div class="form-box">
                <h3 style="margin-top:0;">Créer un Club</h3>
                <form action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" value="creerClub">
                    <input type="text" name="nom" placeholder="Nom du Club" required class="form-control">
                    <textarea name="description" placeholder="Description courte" required class="form-control" rows="3"></textarea>
                    <button type="submit" class="btn-submit">Créer et Initialiser les Rôles</button>
                </form>

                <h3 style="margin-top: 30px;">Supprimer un Club</h3>
                <form action="${pageContext.request.contextPath}/admin" method="post" onsubmit="return confirm('ATTENTION : Supprimer ce club est IRREVERSIBLE et supprime toutes ses données (membres, événements). Confirmez ?');">
                    <input type="hidden" name="action" value="supprimerClub">
                    <select name="clubId" class="form-control" required>
                        <option value="">Choisir le Club à Supprimer</option>
                        <% for (Club c : tousClubs) { %>
                        <option value="<%= c.getClubID() %>"><%= c.getNom() %></option>
                        <% } %>
                    </select>
                    <button type="submit" class="btn-submit" style="background-color: var(--a-primary);">Supprimer Définitivement</button>
                </form>
            </div>

            <div class="form-box">
                <h3 style="margin-top:0;">Assigner un Président</h3>
                <form action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" value="assignerPresident">

                    <input type="number" name="userId" placeholder="ID Utilisateur (voir liste ci-dessous)" required class="form-control" min="1">

                    <select name="clubId" class="form-control" required>
                        <option value="">Choisir le Club</option>
                        <% for (Club c : tousClubs) { %>
                        <option value="<%= c.getClubID() %>"><%= c.getNom() %></option>
                        <% } %>
                    </select>
                    <button type="submit" class="btn-submit" style="background-color: var(--a-warning);">Assigner Rôle Président</button>
                    <small style="display:block; margin-top:5px; color:#666;">Ceci créera l'adhésion si elle n'existe pas et l'activera avec le rôle Président.</small>
                </form>
            </div>
        </div>




        <h3 style="margin-top: 30px;">Recherche et Suppression d'Étudiants</h3>

        <form action="${pageContext.request.contextPath}/admin" method="get" style="margin-bottom: 20px;">
            <input type="hidden" name="tab" value="management">
            <div style="display: flex; gap: 20px; margin-bottom: 10px;">
            <label>
                <input type="radio" name="searchType" value="par_motcle"
                    <%= !"par_email".equals(request.getAttribute("searchType")) ? "checked" : "" %>>
                Par Prénom/Nom
            </label>
            <label>
                <input type="radio" name="searchType" value="par_email"
                    <%= "par_email".equals(request.getAttribute("searchType")) ? "checked" : "" %>>
                Par Email Educatif Exact
            </label>
            </div>

            <div style="display:flex; gap:10px;">
                <input type="text" name="motCle"
                       placeholder="Entrez le mot clé ou prenom.nom@edu.uiz.ac.ma "
                       value="<%= motCle %>" class="form-control" style="flex-grow: 1;" required>
                <button type="submit" class="btn-submit" style="width: auto; background-color: var(--a-dark);">Rechercher</button>
            </div>
        </form>

        <table class="admin-table">
            <thead>
            <tr><th>ID</th><th>Nom</th><th>Email</th><th>Niveau</th><th>Action</th></tr>
            </thead>
            <tbody>
            <%
                // ... (La boucle d'affichage existante reste la même) ...
                for (Utilisateur u : listeUtilisateurs) {
            %>
            <tr>
                <td><%= u.getUtilisateurID() %></td>
                <td><%= u.getNomUtilisateur() %></td>
                <td><%= u.getEmail() %></td>
                <td><%= u.getNiveauEtude() %></td>
                <td>
                    <form action="${pageContext.request.contextPath}/admin" method="post" onsubmit="return confirm('SUPPRIMER DÉFINITIVEMENT cet utilisateur ?');" style="display:inline;">
                        <input type="hidden" name="action" value="supprimerUtilisateur">
                        <input type="hidden" name="userId" value="<%= u.getUtilisateurID() %>">
                        <button class="btn-action btn-delete">Supprimer</button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% if (listeUtilisateurs.isEmpty()) { %>
        <p style="margin-top: 15px;">
            Aucun utilisateur trouvé.
            <% if (!motCle.isEmpty()) { %>Vérifiez le terme de recherche et le type de recherche sélectionné.<% } %>
        </p>
        <% } %>
    </div>

</div>
<script>
    // Script pour gérer le basculement entre les onglets et garder l'état après redirection
    function switchTab(tabName) {
        // 1. Cacher toutes les sections et désactiver tous les boutons
        document.querySelectorAll('.section').forEach(section => {
            section.classList.remove('active');
        });
        document.querySelectorAll('.tab-navigation .tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // 2. Afficher la bonne section
        const sectionToShow = document.getElementById(tabName);
        if(sectionToShow) {
            sectionToShow.classList.add('active');
        }

        // 3. Activer le bouton correspondant
        // On recherche le bouton qui a l'attribut onclick contenant le nom de l'onglet
        const buttonToActivate = document.getElementById('btn-' + tabName);        if (buttonToActivate) {
            buttonToActivate.classList.add('active');
        }

        // 4. Mettre à jour l'URL SANS recharger (pour garder l'état de l'onglet actif lors d'une recherche ou d'un rafraîchissement)
        history.pushState(null, '', 'admin?tab=' + tabName);
    }

    document.addEventListener('DOMContentLoaded', () => {
        const urlParams = new URLSearchParams(window.location.search);
        let activeTab = urlParams.get('tab');

        // Si aucun onglet n'est spécifié dans l'URL (ou si la page est chargée pour la première fois),
        // utiliser 'stats' par défaut.
        if (!activeTab) {
            activeTab = 'stats';
        }

        // Vérifier que l'onglet est valide
        if (activeTab === 'stats' || activeTab === 'management') {
            // Initialiser l'affichage en appelant switchTab une seule fois.
            // La fonction gère la visibilité, l'état actif des boutons, et l'URL.
            switchTab(activeTab);
        }


    });
</script>

</body>
</html>