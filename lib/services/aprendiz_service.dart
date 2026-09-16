import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/aprendiz.dart';

class AprendizService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Aprendiz>> obtenerAprendices() async {
    final response = await _supabase
        .from('aprendiz')
        .select()
        .order('id', ascending: true);

    return (response as List)
        .map((item) => Aprendiz.fromMap(item))
        .toList();
  }

  Future<void> crearAprendiz(Aprendiz aprendiz) async {
    await _supabase.from('aprendiz').insert(aprendiz.toMap());
  }

  Future<void> actualizarAprendiz(Aprendiz aprendiz) async {
    await _supabase
        .from('aprendiz')
        .update(aprendiz.toMap())
        .eq('id', aprendiz.id);
  }

  Future<void> eliminarAprendiz(int id) async {
    await _supabase.from('aprendiz').delete().eq('id', id);
  }
}
